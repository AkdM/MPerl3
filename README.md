#MPerl3 - v1.0 ß1

##Intro

MPerl3 is a tool in Perl that allows you to tag your MP3 files : 
* Track #
* Title
* Artist
* Album
* Year
* Genre
* Cover (jpg)

MPerl3 can also sort the selected musics in their respective folders by copying or moving the tagged MP3, in this format :

`artist/album/track# - title.mp3`


##Dependencies 

To get MPerl3 properly working, you will have to install some dependencies.

#####MP3::Tag
Type this command to install it (OS X — Make sure you installed the Command Line Tools for Xcode)

```
sudo cpan install MP3::Tag
```

#####Time::HiRes
Type this command to install it (OS X — Make sure you installed the Command Line Tools for Xcode)

```
sudo cpan install Time::HiRes
```


##Usage

On OS X, simply run perl the script in the Terminal (Applications/Terminal.app)

```
perl MPerl3.pl
```

####Example screen
```
Welcome to the MPerl3		Version 1.0 ß1

Music Path (drag&drop): /Users/AkdM/Documents/Dev/MPerl3/Example/    


Now Processing : Ramones.mp3 (1.36Mb)

Track # [01]:   
Title [Ramones]: 
Artist [Motorhead]: 
Album [1916]: 
Genre [Heavy Metal]: 
Year [1991]: 
Add/Modify cover [no]: yes
Image file : /Users/AkdM/Desktop/cover.jpg 


Copy or Move ?[move]: copy


Copying .mp3 : Motorhead/1916/01 - Ramones.mp3


Press any key to continue
Thanks !

#################################################################
######################## Created by AkdM ########################
#################################################################
```


##Known issues & TODO
####Issues
* The 'Genre' and 'Cover' fields don't always update their metadatas - `?`
* Writing of ID3v2.4 is not fully supported - `Will be fixed in the next version`

####TODO
* PHP integration
