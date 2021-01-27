Imports System.IO

Module Main

    Dim cdir As String = Nothing

    Sub Main()
        'Get command line arguments
        Dim s() As String = Environment.GetCommandLineArgs()
        For i = 0 To s.Length - 1
            If LCase(s(i)) = "silent" Then
                GoTo RunCertUpdater
            End If
        Next

        'This gets skipped if silent is specified
        Console.WriteLine()
        Console.WriteLine("Greetings! Please note that you MUST be connected to the Internet for this program to work.")
        Console.WriteLine()
        Console.WriteLine("Use the ""silent"" argument to run, for example:")
        Console.WriteLine("    RootCertUpdaterCmd.exe silent")
        Console.WriteLine()
        End

RunCertUpdater:

        'Create a directory to hold the files
        Dim r As New Random
        cdir = Path.GetTempPath & "RCU_" & r.Next(1000, 100000).ToString

        Try
            'Prenotify
            Dim prenotify1 As String = "Here we go... this process is super fast!"
            Console.WriteLine(prenotify1)
            Console.WriteLine()

            'Prep folder
            If Directory.Exists(cdir) = False Then Directory.CreateDirectory(cdir)

            'Download certs in STL format
            Dim authroot As String = "http://ctldl.windowsupdate.com/msdownload/update/v3/static/trustedr/en/authrootstl.cab"
            Dim authrootfile As String = cdir & "\authrootstl.cab"
            Dim a = New Net.WebClient
            a.DownloadFile(authroot, authrootfile)
            Dim disallowed As String = "http://ctldl.windowsupdate.com/msdownload/update/v3/static/trustedr/en/disallowedcertstl.cab"
            Dim disallowedfile As String = cdir & "\disallowedcertstl.cab"
            a.DownloadFile(disallowed, disallowedfile)

            'Extract 7z
            Dim b As Byte() = My.Resources._7z2
            IO.File.WriteAllBytes(cdir & "\7z.exe", b)

            'Extract
            Dim z As New Process
            z.StartInfo.WindowStyle = ProcessWindowStyle.Hidden
            z.StartInfo.FileName = cdir & "\7z.exe"
            z.StartInfo.WorkingDirectory = cdir
            z.StartInfo.Arguments = "e authrootstl.cab"
            z.Start()
            z.StartInfo.Arguments = "e disallowedcertstl.cab"
            z.Start()

            'Run certutil
            Dim k As New Process
            k.StartInfo.WindowStyle = ProcessWindowStyle.Hidden
            k.StartInfo.WorkingDirectory = cdir
            k.StartInfo.FileName = "certutil.exe"
            k.StartInfo.Arguments = "-addstore -f root authroot.stl"
            k.Start()
            k.StartInfo.Arguments = "-addstore -f disallowed disallowedcert.stl"
            k.Start()

            'Notify
            Dim notify1 As String = "The root certificates were successfully downloaded and installed." + vbCrLf + "You need to restart the computer for changes to take effect."
            Console.WriteLine(notify1)
            Console.WriteLine()

            'Delete temp directory
            Try
                Directory.Delete(cdir, True)
            Catch ex As Exception

            End Try
        Catch ex As Exception
            Dim err1 As String = "An error has occurred. Please e-mail support@asher.tools with the following error message." + vbCrLf + "We will get back with you to resolve the issue."
            Dim err2 As String = "----------------------"
            Dim err3 As String = "Error: " + ex.ToString
            Dim err4 As String = "----------------------"
            Console.WriteLine(err1)
            Console.WriteLine(err2)
            Console.WriteLine(err3)
            Console.WriteLine(err4)

            End
        End Try
    End Sub

End Module