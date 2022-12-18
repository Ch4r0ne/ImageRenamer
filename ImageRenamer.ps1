# Load required assembly
[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null

# Make sure to adjust the path of the folder containing the image files before running the script. 
# Example path: "C:\Users\Username\Documents\ImageFolder".
$folderPath = "C:\Users\Username\Documents\ImageFolder"

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
      Write-Output "The image file $($_.Name) does not contain metadata with the date taken and was not renamed."
      $newFileName = $null  # No valid new file name present
    }

    # Close image file
    $image.Dispose()

    # Rename image file if a valid new file name is present
    if ($newFileName) {
      Rename-Item $_.FullName -NewName $newFileName
      Write-Output "Image file $($_.Name) was renamed to $newFileName."
    }
  }
}
