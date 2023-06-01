Imports System.ComponentModel
Imports System.IO
Imports System.Net

Public Class MainWindow

    Dim cdir As String = Nothing

    Private Sub Button_Go_Click(sender As Object, e As EventArgs) Handles Button_Go.Click
        Try

            'Prenotify
            MessageBox.Show("Here we go... this process is super fast!", "Notice", MessageBoxButtons.OK, MessageBoxIcon.Information)

            'Disable button control
            Button_Go.Enabled = False

            'Prep temp folder
            If Directory.Exists(cdir) = False Then Directory.CreateDirectory(cdir)

            'Download certs
            Dim authroot As String = "http://ctldl.windowsupdate.com/msdownload/update/v3/static/trustedr/en/authrootstl.cab"
            Dim authrootfile As String = cdir & "\authrootstl.cab"
            Dim a = New Net.WebClient
            a.DownloadFile(authroot, authrootfile)
            Dim disallowed As String = "http://ctldl.windowsupdate.com/msdownload/update/v3/static/trustedr/en/disallowedcertstl.cab"
            Dim disallowedfile As String = cdir & "\disallowedcertstl.cab"
            a.DownloadFile(disallowed, disallowedfile)

            'Extract    
            Dim b As Byte() = My.Resources._7z
            File.WriteAllBytes(cdir & "\7z.exe", b)

            'Extract certificates from cab archives
            Dim z As New Process
            z.StartInfo.WindowStyle = ProcessWindowStyle.Hidden
            z.StartInfo.FileName = cdir & "\7z.exe"
            z.StartInfo.WorkingDirectory = cdir
            z.StartInfo.Arguments = "e authrootstl.cab"
            z.Start()
            z.StartInfo.Arguments = "e disallowedcertstl.cab"
            z.Start()

            'Run certutil to apply certificates
            Dim k As New Process
            k.StartInfo.WindowStyle = ProcessWindowStyle.Hidden
            k.StartInfo.WorkingDirectory = cdir
            k.StartInfo.FileName = "certutil.exe"
            k.StartInfo.Arguments = "-addstore -f root authroot.stl"
            k.Start()
            k.StartInfo.Arguments = "-addstore -f disallowed disallowedcert.stl"
            k.Start()
            k.StartInfo.Arguments = "-addstore -f disallowed disallowedcert.stl"
            k.Start()

            'Change button text
            Button_Go.Text = "ROOT CERTIFICATES UPDATED"

            'Notify
            MessageBox.Show("The root certificates lists were successfully downloaded and installed. Please restart the computer for changes to take effect. You may click OK and close the program now.", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information)

            'Delete temp directory
            Try
                Directory.Delete(cdir, True)
            Catch ex As Exception

            End Try
        Catch ex As Exception
            MessageBox.Show("An error has occurred. If you could please e-mail support@asher.tools with the following error message, we will get back with you to resolve the issue." + vbNewLine + vbNewLine + ex.ToString)
            Button_Go.Enabled = True
            Exit Sub
        End Try

    End Sub

    Private Sub Main_Load(sender As Object, e As EventArgs) Handles MyBase.Load
        MessageBox.Show("Greetings! Please note that you MUST be connected to the Internet for this program to work.", "Important Notice", MessageBoxButtons.OK, MessageBoxIcon.Information)

        Dim r As New Random
        cdir = Path.GetTempPath & "RCU_" & r.Next(1000, 100000).ToString

        Label_TempPath.Text = cdir
        Timer_AppUpdate.Enabled = True
    End Sub

    Private Sub Label_RootCertCabs_LinkClicked(sender As Object, e As LinkLabelLinkClickedEventArgs) Handles Label_RootCertCabs.LinkClicked
        Try
            Process.Start(Label_RootCertCabs.Text)
        Catch ex As Exception

        End Try
    End Sub

    Private Sub Label_DisallowedCertsCab_LinkClicked(sender As Object, e As LinkLabelLinkClickedEventArgs) Handles Label_DisallowedCertsCab.LinkClicked
        Try
            Process.Start(Label_DisallowedCertsCab.Text)
        Catch ex As Exception

        End Try
    End Sub

    Private Sub Timer_AppUpdate_Tick(sender As Object, e As EventArgs) Handles Timer_AppUpdate.Tick
        Timer_AppUpdate.Enabled = False

        If BackgroundWorker_AppUpdate.IsBusy = False Then BackgroundWorker_AppUpdate.RunWorkerAsync()
    End Sub

    Private Sub BackgroundWorker_AppUpdate_DoWork(sender As Object, e As DoWorkEventArgs) Handles BackgroundWorker_AppUpdate.DoWork
        Try
            Dim hasConnection As Boolean = My.Computer.Network.Ping("api.asher.tools")
            If hasConnection = False Then Throw New Exception("Cannot ping asher.tools")

            Dim api_data = New WebClient().DownloadString("https://api.asher.tools/software/root-certificate-updater")
            Dim api_ashertools As API = JsonConvert.DeserializeObject(Of API)(api_data)

            Dim latest_version = New Version(api_ashertools.version_number)
            Dim my_version = New Version(My.Application.Info.Version.ToString)
            Dim result = latest_version.CompareTo(my_version)

            If result > 0 Then
                'Newer version available
                Me.Invoke(Sub()
                              Dim ask = MsgBox("Newer version available, click OK to Download.", vbInformation + vbOKCancel)

                              If ask = vbOK Then
                                  Dim x As New Process
                                  x.StartInfo.UseShellExecute = True
                                  x.StartInfo.FileName = api_ashertools.download_url
                                  x.StartInfo.WindowStyle = ProcessWindowStyle.Normal
                                  x.Start()
                              End If
                          End Sub)
            Else
                'No newer version available
            End If
        Catch ex As Exception

        End Try
    End Sub

    Private Sub ThirdPartyLicenseInfo_LinkClicked(sender As Object, e As LinkLabelLinkClickedEventArgs) Handles ThirdPartyLicenseInfo.LinkClicked
        Try
            Process.Start("https://github.com/asheroto/Root-Certificate-Updater/blob/master/LICENSE")
        Catch ex As Exception

        End Try
    End Sub

    Private Sub MoreInfoCTL_LinkClicked(sender As Object, e As LinkLabelLinkClickedEventArgs) Handles MoreInfoCTL.LinkClicked
        Try
            MsgBox("This program will update the Certificate Trust Lists on your computer. Root certificate lists have the hashes of the certificates and don't contain the 'actual' certificates themselves, HOWEVER, this is because when a Windows machine encounters a new certificate that is on the trust list that it hasn't seen before, it will automatically download the needed certificate behind-the-scenes (on demand). The reason we use Certificate Trust Lists instead of the 'actual' certificates is because Windows Update is required to generate the certificates using certutil. If Windows Update is enabled and in use, that means your root certificates would already be up-to-date as it handles root certificate updates automatically. Using this method, we're able to achieve our goal of having the latest root certificates without relying on Windows Update." + vbCrLf + vbCrLf + "Reference: https://bit.ly/ms-ctl-info", vbInformation, MoreInfoCTL.Text)
        Catch ex As Exception

        End Try
    End Sub
End Class

Public Class API
    Private m_version_number As String

    Public Property version_number As String
        Get
            Return m_version_number
        End Get
        Set(value As String)
            m_version_number = value
        End Set
    End Property

    Private m_download_url As String

    Public Property download_url As String
        Get
            Return m_download_url
        End Get
        Set(value As String)
            m_download_url = value
        End Set
    End Property

End Class