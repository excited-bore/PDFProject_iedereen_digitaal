try{
        Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
        function New-TemporaryDirectory {
            $tmp = [System.IO.Path]::GetTempPath() # Not $env:TEMP, see https://stackoverflow.com/a/946017
            $name = (New-Guid).ToString("N")
            New-Item -ItemType Directory -Path (Join-Path $tmp $name)
        }
        # Tesseract 
        if (-not (Test-Path 'C:\Program Files\Tesseract-OCR' -ErrorAction SilentlyContinue)){
            $tmp = New-TemporaryDirectory
            Invoke-WebRequest -Uri 'https://github.com/tesseract-ocr/tesseract/releases/download/5.5.0/tesseract-ocr-w64-setup-5.5.0.20241111.exe' -OutFile "$env:TEMP\tesseract_setup.exe"
            & "$env:TEMP\tesseract_setup.exe"
        }

        if (-not (Test-Path 'C:\Program Files\Tesseract-OCR\tessdata\nld.traineddata' -ErrorAction SilentlyContinue)){
            Start-Process powershell -Verb runAs -ArgumentList "-NoProfile", "-Command", "Invoke-WebRequest -Uri 'https://github.com/tesseract-ocr/tessdata_best/raw/refs/heads/main/nld.traineddata' -OutFile 'C:\Program Files\Tesseract-OCR\tessdata\nld.traineddata'"
        }

        # Poppler
        if (-not (Test-Path 'C:\Program Files\poppler\Library' -ErrorAction SilentlyContinue)){
            Invoke-WebRequest -Uri 'https://github.com/oschwartz10612/poppler-windows/releases/download/v24.08.0-0/Release-24.08.0-0.zip' -OutFile "$env:TEMP\poppler.zip"
            Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile', '-Command', "Expand-Archive -Path `"$env:TEMP\poppler.zip`" -DestinationPath 'C:\Program Files\'"
            Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile', '-Command', "Rename-Item -Path 'C:\Program Files\poppler-24.08.0' -NewName 'poppler'"
        }
        
        $env:PATH += ";C:\Program Files\poppler\Library\bin"

        # Check if python is installed

        $p = &{python -V} 2>&1

        # Check if an ErrorRecord was returned
        if($p -is [System.Management.Automation.ErrorRecord]){
            
            # If not, install python 3.13
            winget install 9PNRBTZXMB4Z
        }

        if (-not (Test-Path '.\.venv' -ErrorAction SilentlyContinue)){
            python -m venv .venv
        }

        & .venv\Scripts\activate.ps1

        pip install pytesseract pdf2image

        python .\script.py
    }
catch {
    #Do Nothing
}

