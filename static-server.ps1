$ErrorActionPreference = "Stop"

$root = (Get-Location).Path
$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Parse("127.0.0.1"), 8080)
$listener.Start()
Write-Host "Serving $root at http://127.0.0.1:8080/"

function Get-ContentType($path) {
  $extension = [System.IO.Path]::GetExtension($path).ToLowerInvariant()
  switch ($extension) {
    ".html" { "text/html; charset=utf-8" }
    ".css" { "text/css; charset=utf-8" }
    ".js" { "text/javascript; charset=utf-8" }
    ".svg" { "image/svg+xml" }
    ".png" { "image/png" }
    ".jpg" { "image/jpeg" }
    ".jpeg" { "image/jpeg" }
    ".webp" { "image/webp" }
    default { "application/octet-stream" }
  }
}

function Send-Response($stream, $status, $contentType, [byte[]]$body) {
  $header = "HTTP/1.1 $status`r`nContent-Type: $contentType`r`nContent-Length: $($body.Length)`r`nConnection: close`r`n`r`n"
  $headerBytes = [System.Text.Encoding]::ASCII.GetBytes($header)
  $stream.Write($headerBytes, 0, $headerBytes.Length)
  $stream.Write($body, 0, $body.Length)
}

try {
  while ($true) {
    $client = $listener.AcceptTcpClient()

    try {
      $stream = $client.GetStream()
      $reader = [System.IO.StreamReader]::new($stream, [System.Text.Encoding]::ASCII, $false, 1024, $true)
      $requestLine = $reader.ReadLine()

      if ([string]::IsNullOrWhiteSpace($requestLine)) {
        $client.Close()
        continue
      }

      $parts = $requestLine.Split(" ")
      $requestPath = "/"
      if ($parts.Length -ge 2) {
        $requestPath = $parts[1].Split("?")[0]
      }

      while (($line = $reader.ReadLine()) -ne $null -and $line.Length -gt 0) {}

      $relativePath = [Uri]::UnescapeDataString($requestPath.TrimStart("/"))
      if ([string]::IsNullOrWhiteSpace($relativePath)) {
        $relativePath = "index.html"
      }

      $target = [System.IO.Path]::GetFullPath((Join-Path $root $relativePath))

      if (-not $target.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase) -or -not (Test-Path -LiteralPath $target -PathType Leaf)) {
        $notFound = [System.Text.Encoding]::UTF8.GetBytes("Not found")
        Send-Response $stream "404 Not Found" "text/plain; charset=utf-8" $notFound
        $client.Close()
        continue
      }

      $body = [System.IO.File]::ReadAllBytes($target)
      Send-Response $stream "200 OK" (Get-ContentType $target) $body
      $client.Close()
    }
    catch {
      $client.Close()
    }
  }
}
finally {
  $listener.Stop()
}
