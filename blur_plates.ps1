Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$basePath = "c:\Users\User\wairimu dream defensive driving school"

# Find all potential car images
$images = Get-ChildItem -Path "$basePath\images" -Include *.jpg, *.jpeg, *.png -Recurse | Where-Object { 
    $_.Name -match "sienta" -or 
    $_.Name -match "tuktuk" -or 
    $_.Name -match "taxi" -or 
    $_.Name -match "hero" -or
    $_.Name -match "baige" -or
    $_.Name -match "demio" -or
    $_.Name -match "truck" -or
    $_.Name -match "van" -or
    $_.Name -match "b1" -or
    $_.Name -match "b2" -or
    $_.Name -match "b3" -or
    $_.Name -match "c1" -or
    $_.Name -match "c2" -or
    $_.Name -match "d1" -or
    $_.Name -match "d2"
}

foreach ($file in $images) {
    $fullPath = $file.FullName
    $img = [System.Drawing.Image]::FromFile($fullPath)
    
    # Create a clone so we don't lock the file
    $bitmap = new-object System.Drawing.Bitmap($img)
    $img.Dispose()

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Blur Plate - $($file.Name) - Draw a box over the plate numbers to hide them."
    $form.WindowState = "Maximized"
    
    $pictureBox = New-Object System.Windows.Forms.PictureBox
    $pictureBox.Image = $bitmap
    $pictureBox.SizeMode = "Zoom"
    $pictureBox.Dock = "Fill"
    $pictureBox.Cursor = [System.Windows.Forms.Cursors]::Cross

    $form.Controls.Add($pictureBox)

    $isDrawing = $false
    $rectStart = New-Object System.Drawing.Point(0, 0)

    $pictureBox.add_MouseDown({
        $isDrawing = $true
        $rectStart = $args[1].Location
    })

    $pictureBox.add_MouseUp({
        if ($isDrawing) {
            $isDrawing = $false
            $rectEnd = $args[1].Location
            
            # Map pictureBox coordinates to image coordinates
            $picWidth = $pictureBox.ClientSize.Width
            $picHeight = $pictureBox.ClientSize.Height
            $imgWidth = $bitmap.Width
            $imgHeight = $bitmap.Height

            $ratioX = [double]$picWidth / $imgWidth
            $ratioY = [double]$picHeight / $imgHeight
            $ratio = [Math]::Min($ratioX, $ratioY)

            $imgRectWidth = [int]($imgWidth * $ratio)
            $imgRectHeight = [int]($imgHeight * $ratio)

            $imgX = ($picWidth - $imgRectWidth) / 2
            $imgY = ($picHeight - $imgRectHeight) / 2

            if ($rectStart.X -ge $imgX -and $rectStart.X -le ($imgX + $imgRectWidth) -and
                $rectStart.Y -ge $imgY -and $rectStart.Y -le ($imgY + $imgRectHeight)) {

                $realStartX = [int](($rectStart.X - $imgX) / $ratio)
                $realStartY = [int](($rectStart.Y - $imgY) / $ratio)
                $realEndX = [int](($rectEnd.X - $imgX) / $ratio)
                $realEndY = [int](($rectEnd.Y - $imgY) / $ratio)

                $x = [Math]::Min($realStartX, $realEndX)
                $y = [Math]::Min($realStartY, $realEndY)
                $w = [Math]::Abs($realStartX - $realEndX)
                $h = [Math]::Abs($realStartY - $realEndY)

                if ($w -gt 0 -and $h -gt 0) {
                    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
                    $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Black)
                    $graphics.FillRectangle($brush, $x, $y, $w, $h)
                    $graphics.Dispose()
                    $pictureBox.Invalidate()
                }
            }
        }
    })

    $pnlButtons = New-Object System.Windows.Forms.Panel
    $pnlButtons.Dock = "Bottom"
    $pnlButtons.Height = 50

    $btnSave = New-Object System.Windows.Forms.Button
    $btnSave.Text = "Save and Next"
    $btnSave.Dock = "Left"
    $btnSave.Width = 300
    $btnSave.Font = New-Object System.Drawing.Font("Arial", 16)
    $btnSave.add_Click({
        # Ensure we keep the original format. Default is PNG if we just pass path, but we'll infer.
        if ($fullPath.EndsWith(".png")) {
            $bitmap.Save($fullPath, [System.Drawing.Imaging.ImageFormat]::Png)
        } else {
            $bitmap.Save($fullPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)
        }
        $form.Close()
    })
    
    $btnSkip = New-Object System.Windows.Forms.Button
    $btnSkip.Text = "Skip (No plates here)"
    $btnSkip.Dock = "Fill"
    $btnSkip.Font = New-Object System.Drawing.Font("Arial", 16)
    $btnSkip.add_Click({
        $form.Close()
    })

    $pnlButtons.Controls.Add($btnSkip)
    $pnlButtons.Controls.Add($btnSave)

    $form.Controls.Add($pnlButtons)
    $pnlButtons.BringToFront()

    $form.ShowDialog() | Out-Null
    $bitmap.Dispose()
}

Write-Host "All done! You can close this window now."
