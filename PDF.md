# Reducing PDF size when DPI too high:

in the terminal:

    `gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH -    sOutputFile=out.pdf in.pdf`

    ```
    -dPDFSETTINGS=/screen   (screen-view-only quality, 72 dpi images)
    -dPDFSETTINGS=/ebook    (low quality, 150 dpi images)
    -dPDFSETTINGS=/printer  (high quality, 300 dpi images)
    -dPDFSETTINGS=/prepress (high quality, color preserving, 300 dpi imgs)
    -dPDFSETTINGS=/default  (almost identical to /screen)
    ```
  
# Merge pages in a pdf:

See manual pages:
`pdfunite`

# Split pages:

See manual pages:
`pdfseparate`
