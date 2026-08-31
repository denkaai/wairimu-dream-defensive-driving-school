$port = 3000
$listener = New-Object System.Net.HttpListener
$prefix = "http://localhost:$port/"
$listener.Prefixes.Add($prefix)
$listener.Start()
Write-Host "Local server running at: $prefix"

$mimeMap = @{
    ".html" = "text/html; charset=utf-8"
    ".css"  = "text/css; charset=utf-8"
    ".js"   = "application/javascript; charset=utf-8"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".svg"  = "image/svg+xml"
    ".ico"  = "image/x-icon"
    ".mp4"  = "video/mp4"
}

while ($listener.IsListening) {
    try {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        $rawUrl = $request.Url.LocalPath
        if ($rawUrl -eq "/" -or $rawUrl -eq "") {
            $rawUrl = "/index.html"
        }

        # Resolve local file path safely
        $decodedUrl = [System.Uri]::UnescapeDataString($rawUrl)
        $localPath = Join-Path (Get-Location) ($decodedUrl.TrimStart('/'))

        if (Test-Path $localPath -PathType Leaf) {
            $ext = [System.IO.Path]::GetExtension($localPath).ToLower()
            $contentType = if ($mimeMap.ContainsKey($ext)) { $mimeMap[$ext] } else { "application/octet-stream" }
            
            $bytes = [System.IO.File]::ReadAllBytes($localPath)
            $response.ContentType = $contentType
            $response.ContentLength64 = $bytes.Length
            $response.StatusCode = 200
            try {
                $response.OutputStream.Write($bytes, 0, $bytes.Length)
            } catch {
                # Client disconnected before write completed
            }
        } else {
            $response.StatusCode = 404
            $errBytes = [System.Text.Encoding]::UTF8.GetBytes("<h1>404 Not Found</h1>")
            $response.ContentType = "text/html"
            $response.ContentLength64 = $errBytes.Length
            try {
                $response.OutputStream.Write($errBytes, 0, $errBytes.Length)
            } catch {
                # Client disconnected
            }
        }
        try {
            $response.OutputStream.Close()
        } catch {}
    } catch {
        # Catch any request processing errors and keep listener running
    }
}
