# 简单的 HTTP 服务器脚本
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://localhost:8000/')
$listener.Start()
Write-Host '服务器已启动，访问 http://localhost:8000'

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response
    
    # 处理请求路径
    $path = $request.Url.LocalPath
    if ($path -eq '/' -or $path -eq '') {
        $filePath = '.\index.html'
    } else {
        $filePath = '.\' + $path.TrimStart('/')
    }
    
    # 检查文件是否存在
    if (Test-Path $filePath -PathType Leaf) {
        try {
            # 读取文件内容
            $content = Get-Content -Path $filePath -Raw
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
            
            # 设置响应头
            $response.ContentType = 'text/html'
            $response.ContentLength64 = $buffer.Length
            
            # 发送响应
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
        } catch {
            $response.StatusCode = 500
            $errorMsg = "Internal Server Error: $($_.Exception.Message)"
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($errorMsg)
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
        }
    } else {
        # 文件不存在，返回 404
        $response.StatusCode = 404
        $buffer = [System.Text.Encoding]::UTF8.GetBytes('404 Not Found')
        $response.ContentLength64 = $buffer.Length
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
    }
    
    # 关闭响应
    $response.Close()
}

# 停止服务器
$listener.Stop()
$listener.Close()