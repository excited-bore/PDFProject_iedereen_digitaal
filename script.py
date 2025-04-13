import glob
import os

from pdf2image import convert_from_path
import pytesseract
pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'


pdfs = glob.glob(r"*.pdf")

for pdf_path in pdfs:
    pages = convert_from_path(pdf_path, 500)
    voornaam=''
    achternaam=''
    for pageNum,imgBlob in enumerate(pages):
        text = pytesseract.image_to_string(imgBlob,lang='nld')

        found=False
        for item in text.split("\n"):
            if "Iedereen Digitaal @ Leuven" in item:
                found=1
            if found == 3:
                voornaam=item
            if found == 4:
                achternaam=item
                break
            if found:
                found+=1
    
    nieuwe_naam=voornaam + '_' + achternaam + '_bruikleenformulier.pdf'
    os.rename(pdf_path, nieuwe_naam)