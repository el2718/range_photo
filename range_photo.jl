#for julia 1.0
dir_import="/import/"
dir_ranged="/ranged/"


print(dir_import)
if !isdir(dir_ranged)
	mkdir(dir_ranged)
end

dir_ranged_other=string(dir_ranged,"non-photo/")
if !isdir(dir_ranged_other)
	mkdir(dir_ranged_other)
end

photo=readlines(`find $dir_import -type f`)
nphoto=length(photo)

print("\n nphoto=",nphoto,'\n')

picture_type="png,PNG,jpg,JPG,jpeg,JPEG,tiff,TIFF,bmp,BMP,raw,RAW,heic,HEIC"
heic_type="heic,HEIC"
media_type="mov,MOV,mp4,MP4,m4a,M4A,3gp,3GP,3g2,3G2,mj2,MJ2,mkv,MKV,mp3,MP3,wav,WAV,avi,AVI,wmv,WMV,mts,MTS"

for i=1:nphoto
	photo_original=photo[i]

	print('\n', i, '\n',"original: ", photo_original, '\n')
	
	photo_name_tmp=rsplit(photo_original,"/")
	photo_type_tmp=rsplit(photo_original,".")
	photo_name=photo_name_tmp[end]
	photo_type=photo_type_tmp[end]

	is_picture= occursin(photo_type, picture_type)	
	is_media= occursin(photo_type, media_type)

	index=nothing
	
	if is_picture 
		is_heic= occursin(photo_type, heic_type)
		if is_heic
			dir_orig=dirname(photo_original)
			photo_name_tmp2=rsplit(photo_name,".")
			photo_jpg=string(dir_orig,"/",photo_name_tmp2[1],".jpg")
			info=readchomp(Cmd(`heif-convert $photo_original -q 100 $photo_jpg`,ignorestatus=true))
			
			if length(info) == 0
				print("rm ",photo_original,'\n')
				rm(photo_original)
				continue
			end
			rm(photo_original)
			photo_name=string(photo_name_tmp2[1],".jpg")
			photo_original=photo_jpg
		end
		
		if isfile(photo_original)
			info=readchomp(Cmd(`exiftime $photo_original`,ignorestatus=true))
			index=findfirst("Image Digitized:",info)
			if index == nothing
				index=findfirst("Image Generated:",info)
			end
			if index == nothing
				index=findfirst("Image Created:",info)
			end
			
			if index == nothing
			 	info=readchomp(Cmd(`exiftags $photo_original`,ignorestatus=true))
				index=findfirst("Date (UTC):",info)
			end
			

			if index == nothing
				info=readchomp(Cmd(`identify -verbose $photo_original`,ignorestatus=true))
				index=findfirst("exif:DateTimeOriginal:",info)
			end
			
#			if index == nothing
#				info=readchomp(Cmd(`exif -x $photo_original`,ignorestatus=true))
#				index=findfirst("<Date_and_Time__Original_",info)
#			end						
		end

	end
	
	if is_media 
		info=readchomp(Cmd(`mediainfo --Output=XML $photo_original`,ignorestatus=true))
		index=findfirst("<Encoded_date>UTC",info)
		if index == nothing
			index=findfirst("<Encoded_Date>UTC",info)
		end
	end
	
	if index != nothing # (isn't a picture & isn't a media) or don't have the infomation of date 
		year=info[index[end]+2:index[end]+5]
		month=info[index[end]+7:index[end]+8]
		dir_year=string(dir_ranged,year,"/")
		dir_month=string(dir_year,month,"/")
		
		if !isdir(dir_year)
			mkdir(dir_year)
		end
	
		if !isdir(dir_month)
			mkdir(dir_month)
		end
		
		photo_out=string(dir_month,photo_name)
		
	else
		photo_out=string(dir_ranged_other,photo_name)
	end

	print("out:      ",photo_out,'\n')			
	if !isfile(photo_out)
		mv(photo_original,photo_out)	
	else
		if (photo_original!=photo_out)
			rm(photo_original)
		end
	end
end


photo=readlines(`find $dir_import -type f`)
nphoto=length(photo)
if nphoto ==0	
	dir_import_content=readdir(dir_import)
	n_content=length(dir_import_content)
	if n_content!=0
		curdir=pwd()
		cd(dir_import)	
		for i=1:n_content
			rm(dir_import_content[i], force=true, recursive=true)
		end
		cd(curdir)
	end
end
