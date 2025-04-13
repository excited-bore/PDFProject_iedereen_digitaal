if (-not (Test-Path 'C:\Program Files\Tesseract-OCR' -ErrorAction SilentlyContinue)){
    function New-TemporaryDirectory {
        $tmp = [System.IO.Path]::GetTempPath() # Not $env:TEMP, see https://stackoverflow.com/a/946017
        $name = (New-Guid).ToString("N")
        New-Item -ItemType Directory -Path (Join-Path $tmp $name)
    }
    
    $tmp = New-TemporaryDirectory
    Invoke-WebRequest -Uri 'https://github.com/tesseract-ocr/tesseract/releases/download/5.5.0/tesseract-ocr-w64-setup-5.5.0.20241111.exe' -OutFile "$tmp\tesseract_setup.exe"
    & "$tmp\tesseract_setup.exe"
}

if (-not (Test-Path 'C:\Program Files\Tesseract-OCR\tessdata\nld.traineddata' -ErrorAction SilentlyContinue)){
    Start-Process powershell -Verb runAs -ArgumentList "-NoProfile", "-Command", "Invoke-WebRequest -Uri 'https://github.com/tesseract-ocr/tessdata_best/raw/refs/heads/main/nld.traineddata' -OutFile 'C:\Program Files\Tesseract-OCR\tessdata\nld.traineddata'"
}

# Check if python is installed

$p = &{python -V} 2>&1

# check if an ErrorRecord was returned
if($p -is [System.Management.Automation.ErrorRecord]){
    
    # If not, install python 3.12
    winget install Python.Python.3.12
}

if (-not (Test-Path '.venv' -ErrorAction SilentlyContinue)){
    python -m venv .venv
}

& .venv\Scripts\activate.ps1

pip install pytesseract pdf2image

python .\script.py