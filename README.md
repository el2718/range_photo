# range_photo
Range photos by */year/month/

Edit second line to set your original directory of photos: 
dir_import="/import/"

And edit third line to set the directory of output: 
dir_ranged="/ranged/"

Please check that conmands of heif-convert, mediainfo, exiftime, exiftags and exif are available in the system.

Please run the script under shell by julia 1.0 with the command:
julia range_photo.jl
