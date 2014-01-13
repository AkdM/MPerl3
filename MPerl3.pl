#!/usr/bin/perl
# by AkdM

use File::Basename;
use MP3::Tag;
use File::Copy::Recursive qw(fmove fcopy);
use Time::HiRes qw(usleep);
use File::stat;

use constant COVERART_LOCATOR => "coverart";
use constant PICTURE_TYPE => "Cover (front)";
use constant PICTURE_COMMENT => "Cover Image";
use constant APIC => "APIC";

my $Debug = 0;    # 1 - Don't move files just print the new path

&clearScreen();

print "\nWelcome to the MPerl3\t\tVersion 1.0 ß1\n\n";

usleep(1000000); # Wait for 1 second

$musicsPath = &promptUser("Music Path (drag&drop)"); #Prompt for the music directory
$musicsPath =~ s/\s+$//; #remove trailing spaces


foreach my $listMusic (<$musicsPath/*.mp3>) { # Listing each music on the prompted folder

  my $mp3 = MP3::Tag->new($listMusic); # Creating a new instance of the MP3::Tag module
   
  my ( $title, $track, $artist, $album, $comment, $year, $genre ) = ( $mp3->autoinfo() )[ 0, +1, 2, 3, 4, 5, 6 ]; # Getting the title, track name, artist, album, comment, genre and year

  $track = $track =~ /^([0-9]+)/ ? sprintf "%02d", $1 : undef; # Setting the track number
  $title  = 'Unknown Title'    if $title  !~ /\S/; # Setting the title to "Unknown Title" if no title is set in the current tag
  $artist = 'Unknown Artist'   if $artist !~ /\S/; # Setting the artist to "Unknown Artist" if no artist is set in the current tag
  $album  = 'Unknown Album'    if $album  !~ /\S/; # Setting the album to "Unknown Album" if no album is set in the current tag
  s/[\\\/:*?"<>|]//g for $artist, $album; # Doing things

  &clearScreen();

  print "Now Processing : " . basename($listMusic) . " (" . &fileSize($listMusic) . "Mb)\n\n"; #Show the current processed file

  # Prompt Track #, Title, Artist, Album, Genre, Year and Cover for the current file
  $track = &promptUser("Track # ", $track);
  $title = &promptUser("Title ", $title);
  $artist = &promptUser("Artist ", $artist);
  $album = &promptUser("Album ", $album);
  $genre = &promptUser("Genre ", $genre);
  $year = &promptUser("Year ", $year);
  $coverImagePrompt = &promptUser("Add/Modify cover ", "no");
  if ($coverImagePrompt eq "yes") {
    $coverImage = &promptUser("Image file ");
    $coverImage =~ s/\s+$//; #remove trailing spaces
    $coverImage =~ s/\\//g; #remove antislashes
  }

  &clearScreen();

  # print "\n" . basename($listMusic) . " will now be in this structure :\n\n";

  # $track eq ""
  #   ? print "$artist/$album/$title.mp3"
  #   : print "$artist/$album/$track - $title.mp3";

  $track =~ /^([0-9]+)/ ? sprintf "%02d", $1 : undef; # Setting the track number (again)

  # Add image if replied "yes"
  if ($coverImagePrompt eq "yes") {
    add_image($listMusic,$coverImage);
  }

  my $path =
      defined $track
      ? "$artist/$album/$track - $title.mp3"
      : "$artist/$album/$title.mp3";
   
  # Writing the changes to the file
  $mp3->update_tags({
    track => $track,
    title => $title,
    artist => $artist,
    album => $album,
    genre => $genre,
    year => $year
  });

  $mp3->close(); # Finished processing the current file

  $musicsPath =~ s/\\//g; #remove antislashes
  if ($Debug) {
      print $musicsPath.'/'.$path;
  } else {
      $copyMovePrompt = &promptUser("Copy or Move ?", "move");

      if($copyMovePrompt eq "move") {
        print "\n\nMoving .mp3 : $path\n";
        fmove( $listMusic, $musicsPath.'/'.$path ) or warn "Can't move '$listMusic' !";
      }
      elsif ($copyMovePrompt eq "copy") {
        print "\n\nCopying .mp3 : $path\n";
        fcopy( $listMusic, $musicsPath.'/'.$path ) or warn "Can't copy '$listMusic' !"; 
      }
  }

  print "\n\nPress any key to continue";
   <>;


}

print "Thanks !";

&credits();




   #-------------------------------------------------------------------#
   #                            SUBS                                   #
   #-------------------------------------------------------------------#


sub clearScreen {

    print "\033[2J";    #clear the screen
    print "\033[0;0H"; #jump to 0,0

}

sub fileSize {

   local($file) = @_;

   return sprintf("%.2f", stat($file)->size / 1048576); #Returns de file size in MiB
}

sub promptUser {

   #-------------------------------------------------------------------#
   #  two possible input arguments - $promptString, and $defaultValue  #
   #  make the input arguments local variables.                        #
   #-------------------------------------------------------------------#

   local($promptString,$defaultValue) = @_;

   #-------------------------------------------------------------------#
   #  if there is a default value, use the first print statement; if   #
   #  no default is provided, print the second string.                 #
   #-------------------------------------------------------------------#

   if ($defaultValue) {
      print $promptString, "[", $defaultValue, "]: ";
   } else {
      print $promptString, ": ";
   }

   $| = 1;               # force a flush after our print
   $_ = <STDIN>;         # get the input from STDIN (presumably the keyboard)


   #------------------------------------------------------------------#
   # remove the newline character from the end of the input the user  #
   # gave us.                                                         #
   #------------------------------------------------------------------#

   chomp;

   #-----------------------------------------------------------------#
   #  if we had a $default value, and the user gave us input, then   #
   #  return the input; if we had a default, and they gave us no     #
   #  no input, return the $defaultValue.                            #
   #                                                                 # 
   #  if we did not have a default value, then just return whatever  #
   #  the user gave us.  if they just hit the <enter> key,           #
   #  the calling routine will have to deal with that.               #
   #-----------------------------------------------------------------#

   if ("$defaultValue") {
      return $_ ? $_ : $defaultValue;    # return $_ if it has a value
   } else {
      return $_;
   }
}

sub add_image
  {
    # Find a suitable image and attach it to the suggested mp3 file
    my($mp3_file,$image_file) = @_;

    my $mp3 = MP3::Tag->new($mp3_file);

    # Attempt to read the tags
    $mp3->get_tags();

    my($mime_type,$image_data) = read_image($image_file);
    my $encoding = 0;
    my @apic_parts = ($encoding, $mime_type,
             picture_type_idx(PICTURE_TYPE),
             PICTURE_COMMENT, $image_data);

    if(defined $mp3->{ID3v2}->get_frame(APIC))
      {
        # Modifying an existing image
        $mp3->{ID3v2}->change_frame(APIC,@apic_parts);
      }
    else
      {
        # Create a new frame
        $mp3->{ID3v2}->add_frame(APIC,@apic_parts);
      }
    $mp3->{ID3v2}->write_tag();
    return $image_file;
  }


sub read_image
  {
    # Read the image file
    my($file_name) = @_;

    my $image_type;
    my $image_data;

    if($file_name =~ /\.jpg$/i)
      {
        $image_type = "jpg";
        my $ifh = IO::File->new($file_name);
        if(!defined $ifh)
          {
            error("Failed to open \"$file_name\"");
            return;
          }
        binmode $ifh;

        $image_data = "";

        # This reads the data in 16k chunks, but the images should be small anyway

        while(!$ifh->eof())
          {
            my $c = $ifh->read($image_data,1024*16,length($image_data));
          }
        $ifh = undef;
      }

    return("image/$image_type",$image_data);
  }

sub picture_type_idx
  {
    # Given a picture type string convert it into a number suitable
    # for MP3::Tag
    my($picture_type) = @_;

    # The picture types that are currently understood (from MP3::Tag::ID3v2):
    my @picture_types =
         ("Other", "32x32 pixels 'file icon' (PNG only)", "Other file icon", "Cover (front)", "Cover (back)", "Leaflet page", "Media (e.g. lable side of CD)", "Lead artist/lead performer/soloist","Artist/performer", "Conductor", "Band/Orchestra", "Composer","Lyricist/text writer", "Recording Location", "During recording","During performance", "Movie/video screen capture","A bright coloured fish", "Illustration", "Band/artist logotype","Publisher/Studio logotype");

    # This approach is easy to understand
    for(my $i=0;$i<=$#picture_types;$i++)
      {
        if(lc($picture_type) eq lc($picture_types[$i]))
          {
            return chr($i);
          }
      }
    error("The picture type \"$picture_type\" is not valid");
    return chr(3);
  }

sub credits {

  usleep(800000);

  print "\n\n";
  for (my $i = 0; $i < 65; $i++) {
    print "#";
    usleep(7000);
  }

  print "\n";

  for (my $i = 0; $i < 24; $i++) {
    print "#";
    usleep(7000);
  }

  print " Created by AkdM ";

  for (my $i = 0; $i < 24; $i++) {
    print "#";
    usleep(7000);
  }

  print "\n";
  for (my $i = 0; $i < 65; $i++) {
    print "#";
    usleep(7000);
  }
  print "\n\n";

}
