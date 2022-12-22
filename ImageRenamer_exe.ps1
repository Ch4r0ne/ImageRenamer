# Load required assembly
[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null

# Prompt the user for the path of the folder containing the image files
Write-Output "Example path: C:\Users\Username\Documents\ImageFolder"
$folderPath = Read-Host "Enter the path of the folder containing the image files"

# Check if the specified folder exists
if (-not (Test-Path $folderPath)) {
  Write-Output "The specified folder does not exist."
  return
}

# List of supported image file extensions
$supportedFileTypes = @('.jpg', '.jpeg', '.png')

# Iterate through all files in the specified folder
Get-ChildItem -Path $folderPath -Filter "*.*" | ForEach-Object {
  # Check if the file has a supported file extension
  if ($supportedFileTypes -contains $_.Extension) {
    # Open image file
    $image = [System.Drawing.Image]::FromFile($_.FullName)

    # Check if metadata is present
    if ($image.PropertyIdList.Contains(36867)) {
      # Read date taken
      $dateTaken = $image.GetPropertyItem(36867).Value

      # Format date taken and use as new file name
      $newFileName = [System.Text.Encoding]::ASCII.GetString($dateTaken).Replace(":", "-").Replace(" ", "_") + $_.Extension
      $newFileName = $newFileName -replace '[^\w\.\-]', ''
    }
    else {
      Write-Output "The image file $($_.Name) does not contain metadata"
      $newFileName = $null  # No valid new file name present
    }

    # Close image file
    $image.Dispose()

    # Rename image file if a valid new file name is present
    if ($newFileName) {
      # Check if the new file name already exists in the folder
      if (Test-Path (Join-Path $folderPath $newFileName)) {
        Write-Output "file $newFileName already exists. The image $($_.Name) was not renamed."
      }
      else {
        Rename-Item $_.FullName -NewName $newFileName
        Write-Output "Image file $($_.Name) was renamed to $newFileName."
      }
    }
  }
}

# Wait for the user to press Enter to close the window
Write-Host "Press Enter to close the window."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")