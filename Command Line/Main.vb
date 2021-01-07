Imports System.IO

Module Main

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
        Dim cdir2 As String = Path.GetTempPath()
        Dim logPath2 As String = cdir2 & "RootCertUpdaterCmd-Log.txt"
        Console.WriteLine("The log file when ran silently is stored at " + logPath2)
        End

RunCertUpdater:

        'Create a directory to hold the files
        Dim cdir As String = Path.GetTempPath()
        Dim logPath As String = cdir & "RootCertUpdaterCmd-Log.txt"

        'Create a log file
        If File.Exists(logPath) Then
            Try
                File.Delete(logPath)
            Catch ex As Exception
                Console.WriteLine("Could not delete existing log file! Please restart your computer and try again if the process fails any further.")
                Console.WriteLine()
            End Try
        End If
        Dim logWrite As StreamWriter
        logWrite = My.Computer.FileSystem.OpenTextFileWriter(logPath, True)

        Try
            'Prenotify
            Dim prenotify1 As String = "Here we go... this process is super fast!"
            logWrite.WriteLine(prenotify1)
            logWrite.WriteLine()
            Console.WriteLine(prenotify1)
            Console.WriteLine()

            'Erase existing files
            EraseExisting()

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
            z.StartInfo.Arguments = "-ao e authrootstl.cab"
            z.Start()
            z.StartInfo.Arguments = "-ao e disallowedcertstl.cab"
            z.Start()

            'Run certutil
            Dim k As New Process
            k.StartInfo.WindowStyle = ProcessWindowStyle.Hidden
            k.StartInfo.WorkingDirectory = Environment.GetFolderPath(Environment.SpecialFolder.System)
            k.StartInfo.FileName = "certutil.exe"
            k.StartInfo.Arguments = "--addstore -f disallowed " & cdir & "\disallowedcert.stl"
            k.Start()
            k.StartInfo.Arguments = ""

            'Notify
            Dim notify1 As String = "The root certificates were successfully downloaded and installed." + vbCrLf + "You need to restart the computer for changes to take effect." + vbCrLf + vbCrLf + "Log file stored: " + logPath

            logWrite.WriteLine(notify1)
            logWrite.WriteLine()
            Console.WriteLine(notify1)
            Console.WriteLine()

            EraseExisting()

        Catch ex As Exception
            Dim err1 As String = "An error has occurred. Please e-mail support@asher.tools with the following error message." + vbCrLf + "We will get back with you to resolve the issue."
            Dim err2 As String = "----------------------"
            Dim err3 As String = "Error: " + ex.ToString
            Dim err4 As String = "----------------------"
            logWrite.WriteLine(err1)
            logWrite.WriteLine()
            logWrite.WriteLine(err2)
            logWrite.WriteLine(err3)
            logWrite.WriteLine(err4)
            Console.WriteLine(err1)
            Console.WriteLine()
            Console.WriteLine(err2)
            Console.WriteLine(err3)
            Console.WriteLine(err4)

            End
        End Try
        Try
            logWrite.Close()
        Catch ex As Exception

        End Try


    End Sub

    Private Sub EraseExisting()
        Try
            Dim cdir As String = Path.GetTempPath()
            If File.Exists(cdir + "\authrootstl.cab") Then
                File.Delete(cdir + "\authrootstl.cab")
            End If
            If File.Exists(cdir + "\disallowedcertstl.cab") Then
                File.Delete(cdir + "\disallowedcertstl.cab")
            End If
            If File.Exists(cdir & "\7z.exe") Then
                File.Delete(cdir & "\7z.exe")
            End If
        Catch ex As Exception

        End Try
    End Sub

End Module
