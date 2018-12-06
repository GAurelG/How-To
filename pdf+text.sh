#! /bin/bash
origin=original.pdf
output=outpdf.pdf
i=0
echo "processing $origin to produce an OCR pdf named $output..."
echo "extracting images (should output the pages as images)..."
pdfimages $origin -tiff image

for image in image-*.tif
do
	echo "making OCR for $image..."
        tesseract -l eng $image outpage_$i pdf
	((i+=1))
done
echo "all pages processed, uniting the pdf as $output..."
pdfunite $(ls  outpage_*.pdf) $output
echo "removing images and intermediary pages..."
rm image-*.tif outpage_*.pdf
echo "done!"
