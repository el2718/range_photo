#for julia 1.0
dir="/photo/"
dir_out="/photo_ranged/"



if !isdir(dir_out)
	mkdir(dir_out)
end

dir_out_other=string(dir_out,"non-photo/")
if !isdir(dir_out_other)
	mkdir(dir_out_other)
end

photo=readlines(`find $dir -type f`)
nphoto=length(photo)

print("\n nphoto=",nphoto,'\n')	

picture_type="png,PNG,jpg,JPG,bmp,BMP"
	media_type="mov,MOV,mp4,MP4,m4a,M4A,3gp,3GP,3g2,3G2,mj2,MJ2,mkv,MKV,mp3,MP3,wav,WAV,avi,AVI,wmv,WMV"

for i=2033:nphoto
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
		info0=readchomp(`identify $photo_original`)
		info_tmp0=rsplit(info0,"+0+0 ")
		info_tmp1=rsplit(info_tmp0[1]," ")
		im_size=rsplit(info_tmp1[end],"x")
		width=parse(Int, im_size[1])
		height=parse(Int, im_size[2])
		if (width < 16e3) & (height < 16e3) & (width*height <256e6)
			info=readchomp(`identify -verbose $photo_original`)
			index=findfirst("exif:DateTimeOriginal:",info)		
		else
#			info=readchomp(`exiftime $photo_original`)
#			index=findfirst("Image Digitized:",info)
#			info=readchomp(`exiftags $photo_original`)
#			index=findfirst("Date (UTC):",info)
			info=readchomp(`exif -x $photo_original`)
			index=findfirst("<Date_and_Time__Original_",info)
		end
	end
	
	if is_media 
		info=readchomp(`mediainfo --Output=XML $photo_original`)
		index=findfirst("<Encoded_date>UTC",info)
	end
	#info=readchomp(`stat -c %z $photo_i`)
	
	if index != nothing # (isn't a picture & isn't a media) or don't have the infomation of date 
		year=info[index[end]+2:index[end]+5]
		month=info[index[end]+7:index[end]+8]
		dir_year=string(dir_out,year,"/")
		dir_month=string(dir_year,month,"/")
		
		if !isdir(dir_year)
			mkdir(dir_year)
		end
	
		if !isdir(dir_month)
		  mkdir(dir_month)
		end
		
		photo_out=string(dir_month,photo_name)
		
	else

		photo_out=string(dir_out_other,photo_name)

	end

	print("out:      ",photo_out,'\n')			
	if !isfile(photo_out)
		cp(photo_original,photo_out)		
	end
end	
