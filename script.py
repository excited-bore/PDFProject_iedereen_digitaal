import glob
import os
import shutil

from pdf2image import convert_from_path
#import pytesseract
#pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'

import easyocr
reader = easyocr.Reader(['nl', 'en'])

pdf_directory = os.path.join(os.getcwd(), r'PDFS')

pdfs = glob.glob(os.path.join(pdf_directory, "*.pdf"))

for pdf_path in pdfs:
    pages = convert_from_path(pdf_path, 500)

    image_directory = os.path.join(os.getcwd(), r'Images')
    if not os.path.exists(image_directory):
        os.makedirs(image_directory)

    for pageNum,imgBlob in enumerate(pages):        
        
        # Save pages as images in the pdf
        pages[pageNum].save(image_directory + '/page'+ str(pageNum) +'.jpg', 'JPEG')     
   
    images = glob.glob(image_directory + "/*")
    
    voornaam=''
    achternaam=''
    soort='' 
   
    for num, image in enumerate(images):

        imglist = reader.readtext(image)
    
        for num1, i in enumerate(imglist):
            if i[1] == 'Voornaam':
                voornaam = imglist[num1+1][1]
            
            if i[1] == 'Achternaam':               
                achternaam = imglist[num1+1][1]

            if i[1] == 'Soort':               
                soort = imglist[num1+1][1]
                break
        
        print(voornaam) 
        print(achternaam)
        print(soort)
    
    if voornaam and achternaam and soort: 
        
        voornaam=voornaam.replace(" ", "_") 
        achternaam=achternaam.replace(" ", "_")
        
        nieuwe_naam= os.path.join(pdf_directory, voornaam + '_' + achternaam + "_" + soort + '_bruikleenformulier.pdf')
        
        if not pdf_path == nieuwe_naam: 
            
            if os.path.exists(nieuwe_naam):
                os.remove(nieuwe_naam)

            os.rename(pdf_path, nieuwe_naam)
   
    shutil.rmtree(image_directory)

    # Pytesseract version

    #for pageNum,imgBlob in enumerate(pages):
    #    text = pytesseract.image_to_string(imgBlob)
    # 
    #    print(text)
    #    found=False
    #    prev='' 
    #    for item in text.split("\n"): 
    #        print(str(found) + ' ' + item)
    #        if "Iedereen Digitaal @ Leuven" in item:
    #            found=1
    #        if ('Voornaam' in item and not item == 'Voornaam') or found == 3:
    #            if item.startswith('Voornaam '):
    #                item.replace("Voornaam ", "")
    #            voornaam=item
    #        elif item == 'Voornaam' and not prev == '':
    #            voornaam = prev
    #        if ('Achternaam' in item and not item == 'Achternaam') or found == 4:
    #            if item.startswith('Achternaam '):
    #                item.replace("Achternaam ", "")
    #            achternaam=item
    #        elif item == 'Achternaam' and not prev == '':
    #            achternaam = prev

    #        if 'Soort' in item:
    #            print(item)
    #        if not (item == '' or 'Voornaam' in item or 'Achternaam' in item):
    #            prev=item
    #        if found:
    #            found+=1
    #         
