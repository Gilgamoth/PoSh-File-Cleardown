# File Cleardown
# Copyright (C) 2018 Steve Lunn (gilgamoth@gmail.com)
# Downloaded From: https://github.com/Gilgamoth

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see https://www.gnu.org/licenses/

Clear-Host
Set-PSDebug -strict

$ErrorActionPreference = "SilentlyContinue"

$DebugPreference = "Continue" # For Debug Mode
$DebugPreference = "SilentlyContinue" # For Normal Use

[GC]::Collect()

# *************************** FUNCTION SECTION ***************************

function Fnc_clear_files($fcf_deldate, $fcf_fileloc, $fcf_filetype) {

	$FileFiles = Get-ChildItem -LiteralPath $fcf_fileloc -Include *.$fcf_filetype -Recurse
	foreach($FileFile in $FileFiles){
		#Camera1-Rear_2013-12-13_0013.raw
		#write-host Processing $FileFile.DirectoryName\$FileFile.Name
		$FileDate = get-date($FileFile.LastWriteTime)
		If($fcf_deldate -gt $FileDate) {
			Remove-Item $FileFile.FullName
			Write-Host "Deleted File - $FileFile"
			#$EMailBody += "Deleted File - $FileFile.DirectoryName\$FileFile.Name <BR>"
			$DeletedFileCount += 1
			$DeletedFileSize += $FileFile.Length
		}
	}


	$DeletedFileSize = "{0:N0}" -f ($DeletedFileSize/1MB)
    $FilesChecked = $FileFiles.Count

	Write-Host "$fcf_fileloc - $FilesChecked Files Checked, $DeletedFileCount Files deleted, saving $DeletedFileSize MB"
	$global:EMailBody += "$fcf_fileloc - $FilesChecked Files Checked, $DeletedFileCount Files deleted, saving $DeletedFileSize MB<br>`n"
}

# ****************************** CODE START ******************************

# Declare Variables

$smtpServer = "mail.domain.local"
$smtpEnabled=$True
# SMTP Authorisation
$smtpUser = ""
$smtpPassword = ""

$EMailFrom = "Sender@domain.local"
$EMailTo = "Recipient@domain.local"
$EMailSubject = "File Removal Report"

$DeletedFileCount = 0
$DeletedFileSize = 0

# Location to Clear

$KeepDays=60
$FileLocation = "\\server\path"
$FileType = "001"

$DeleteDate = (Get-Date).AddDays(-$KeepDays)
$global:EMailBody = "Deleting $FileType Files older than $KeepDays Days ("
$global:EMailBody += $DeleteDate.ToString("F")
$global:EMailBody += ")<br>`n"
Fnc_clear_files $DeleteDate $FileLocation $FileType

# Location to Clear

$KeepDays=45
$DeleteDate = (Get-Date).AddDays(-$KeepDays)
$FileLocation = "\\server\path"
$FileType = "*"

$global:EMailBody += "<br>`nDeleting $FileType Files older than $KeepDays Days ("
$global:EMailBody += $DeleteDate.ToString("F")
$global:EMailBody += ")<br>`n"
Fnc_clear_files $DeleteDate $FileLocation $FileType

$smtp = New-Object System.Net.Mail.SmtpClient -argumentList $smtpServer
if($smtpUser) {
	$smtp.Credentials = New-Object System.Net.NetworkCredential -argumentList $smtpUser,$smtpPassword
}

if($smtpEnabled) {
	$message = New-Object System.Net.Mail.MailMessage
	$message.From = New-Object System.Net.Mail.MailAddress($EMailFrom)
	$message.To.Add($EMailTo)
	#$message.CC.Add("a.n.other@bcd.com")
	#$message.BCC.Add("yet.another@cde.com")
	$message.Subject = $EMailSubject
	$message.isBodyHtml = $true
	$message.Body = $EMailBody
	#$attachment = new-object Net.Mail.Attachment($att_filename) 
	#$message.Attachments.Add($attachment)
	$smtp.Send($message)
}