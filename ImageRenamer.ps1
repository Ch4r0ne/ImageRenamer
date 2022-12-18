# Load required assembly
[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null

# Make sure to adjust the path of the folder containing the image files before running the script. 
# Example path: "C:\Users\Username\Documents\ImageFolder".
$folderPath = "C:\Users\Username\Documents\ImageFolder"

# Get all JPG files in the folder
$imageFiles = Get-ChildItem -Path $folderPath -Filter "*.jpg"

foreach ($imageFile in $imageFiles) {
  # Open image file
  $image = [System.Drawing.Image]::FromFile($imageFile.FullName)

  # Check if metadata is present
  if ($image.PropertyIdList.Contains(36867)) {
    # Read date taken
    $dateTaken = $image.GetPropertyItem(36867).Value

    # Format date taken and use as new file name
    $newFileName = [System.Text.Encoding]::ASCII.GetString($dateTaken).Replace(":", "-").Replace(" ", "_") + $imageFile.Extension
    $newFileName = $newFileName -replace '[^\w\.\-]', ''  # Do not allow special characters in file name
  }
  else {
    Write-Output "The image file $($imageFile.Name) does not contain metadata with the date taken and was not renamed."
    $newFileName = $null  # No valid new file name present
  }

  # Close image file
  $image.Dispose()

  # Rename image file if a valid new file name is present
  if ($newFileName) {
    Rename-Item $imageFile.FullName -NewName $newFileName
    Write-Output "Image file $($imageFile.Name) was renamed to $newFileName."
  }
}