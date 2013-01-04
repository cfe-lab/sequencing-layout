#!/usr/bin/perl

    local ($buffer, @pairs, $pair, $name, $value, %FORM);
    # Read in text
    $ENV{'REQUEST_METHOD'} =~ tr/a-z/A-Z/;
    if ($ENV{'REQUEST_METHOD'} eq "POST")
    {
        read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
    }else {
	$buffer = $ENV{'QUERY_STRING'};
    }
    # Split information into name/value pairs
    @pairs = split(/&/, $buffer);
    foreach $pair (@pairs)
    {
	($name, $value) = split(/=/, $pair);
	$value =~ tr/+/ /;
	$value =~ s/%(..)/pack("C", hex($1))/eg;
	$FORM{$name} = $value;
    }
    $first_name = $FORM{first_name};
    $last_name  = $FORM{last_name};

%well = (
         '1' => 'A1',    '2' => 'B1',    '3' => 'C1',  	 '4'  =>  'D1',	 '5' =>  'E1',  '6'  =>  'F1',	'7'  => 'G1',	'8'  => 'H1',
	 '9' => 'A2',	'10' => 'B2',	'11' => 'C2',  	'12'  =>  'D2',	'13' =>	 'E2',	'14' =>	 'F2',	'15' => 'G2',	'16' => 'H2',
	'17' => 'A3',	'18' => 'B3',	'19' => 'C3',	'20'  =>  'D3', '21' =>  'E3',	'22' =>  'F3',	'23' => 'G3',	'24' => 'H3',
	'25' => 'A4',	'26' => 'B4',	'27' => 'C4',	'28'  =>  'D4',	'29' =>  'E4',	'30' =>  'F4',	'31' => 'G4',	'32' => 'H4',
	'33' => 'A5',	'34' => 'B5',	'35' => 'C5',	'36'  =>  'D5',	'37' =>  'E5',	'38' =>  'F5',	'39' => 'G5',	'40' => 'H5',
	'41' => 'A6',	'42' => 'B6',	'43' => 'C6',	'44'  =>  'D6', '45' =>  'E6',	'46' =>  'F6',	'47' => 'G6',	'48' => 'H6',
	'49' => 'A7',	'50' => 'B7',	'51' => 'C7',	'52'  =>  'D7',	'53' =>	 'E7',	'54' =>	 'F7',	'55' => 'G7',	'56' => 'H7',
	'57' => 'A8',	'58' => 'B8',	'59' => 'C8',	'60'  =>  'D8',	'61' =>  'E8',	'62' =>	 'F8',	'63' => 'G8',	'64' => 'H8',
	'65' => 'A9',	'66' => 'B9',	'67' => 'C9',	'68'  =>  'D9', '69' =>  'E9',	'70' =>  'F9',  '71' => 'G9',   '72' => 'H9',
	'73' => 'A10',	'74' => 'B10',	'75' => 'C10',	'76'  =>  'D10','77' =>  'E10',	'78' =>	 'F10', '79' => 'G10',	'80' => 'H10',
	'81' => 'A11',	'82' => 'B11',	'83' => 'C11',	'84'  =>  'D11','85' =>  'E11', '86' =>  'F11', '87' => 'G11',  '88' => 'H11',
	'89' => 'A12',	'90' => 'B12',	'91' => 'C12',	'92'  =>  'D12','93' =>  'E12', '94' =>  'F12', '95' => 'G12',  '96' => 'H12'
);

# ASSUMPTIONS: a '+' on one line represents an empty well, and should be replaced by 'X-X'

print "Content-type:text/html\r\n\r\n";
print '<html><head><meta HTTP-EQUIV="REFRESH" content="3; url=../SEQUENCING/output"></head>';
print '<body>';

$form = $FORM{'manualFields'};
my @lines = split('\n', $form);
$userName = $FORM{'userName'};
$plateID = $FORM{'plateID'};
$email = $FORM{'emailAddress'};
my $sequencingMachine = $FORM{'sequencingMachine'};

if ($sequencingMachine eq "A") { print "Please select a sequencing machine!"; exit; }
if ($sequencingMachine eq "B") { $sequencingMachine = "POP7_BDV3"; }
if ($sequencingMachine eq "C") { $sequencingMachine = "3730BDTv3-KB-DeNovo_v5.2"; }

######## GENERATE THE ABI FILE #########
print "Generating <b>$plateID.plt</b>...";
open(ABI, ">../SEQUENCING/output/$plateID.plt") || die('Error writing PLT file');

print ABI "Container Name\tPlate ID\tDescription\tContainerType\tAppType\tOwner\tOperator\tPlateSealing\tSchedulingPref\n";
print ABI "$plateID\t$plateID\tIMPORT API\t96-Well\tRegular\t$userName\t$userName\tSepta\t1234\n";
print ABI "AppServer\tAppInstance\t\t\t\t\t\t\t\n";
print ABI "SequencingAnalysis\t\t\t\t\t\t\t\t\n";
print ABI "Well\tSample Name\tComment\tResults Group 1\tInstrument Protocol 1\tAnalysis Protocol 1\n";

my $count = 1;
foreach $line (@lines) {
	chomp $line;
	$line =~s/\r//;

	my $analysisProtocolOne;

	print ABI $well{$count++} . "\t" . $line . "\t" . "SFU" . "\t" . "CFE_Results_Group" . "\t" . "CFE_DEFAULT" . "\t" . $sequencingMachine . "\t\t\t";
	print ABI "\n";
	}

close ABI;
print " done!<br/>";

########## GENERATE LAYOUT FILE ##########
print "Generating layout file: <b>$plateID" . "_Layout.html</b> ...";

open (TMP, ">../SEQUENCING/output/$plateID" . "_Layout.tmp") || die('Error writing TMP file');
$newLineCount = 0;
$count = 0;
while ($count != 95) {
	if($newLineCount++ >= 12) { $newLineCount -= 12; print TMP "\n"; }
	print TMP $lines[$count] . "\t";
	if($count <= 87) { $count += 8; } else { $count -= 87; }
	}
print TMP $lines[$count] . "\t";
close TMP;


open (TMP, "../SEQUENCING/output/$plateID" . "_Layout.tmp") || die('Error reading TMP file');
my @lines = <TMP>;
close TMP;

open (LAYOUT, ">../SEQUENCING/output/$plateID" ."_Layout.html") || die('Error writing LAYOUT file');

print LAYOUT "<html><head><style type=\"text/css\">table { border-width: 0 0 1px 1px; border-style:solid; } td { border-color: #600; border-width: 1px 1px 0 0; border-style: solid; margin: 0; padding: 4px; text-align:center; } tr.even { background-color:#EEEEEE; } tr.odd { background-color:#FFFFFF }</style></head><body>";
print LAYOUT "<h1>SEQUENCING LAYOUT</h1>";
print LAYOUT "<h2>Plate ID: $plateID, User name: $userName</h2>";
print LAYOUT "\n<table border=\"1\">\n";
print LAYOUT "<tr>\t<td>*</td><td>1</td><td>2</td><td>3</td><td>4</td><td>5</td><td>6</td><td>7</td><td>8</td><td>9</td><td>10</td><td>11</td><td>12</td></tr>\n";

%well = (
         '1'=>'A',  '2'=>'B',  '3'=>'C', '4'=>'D',  '5'=>'E',  '6'=>'F',  '7'=>'G',   '8'=>'H',
);

$wellNumber = 1;

foreach $line (@lines) {				# For each line containing 12 entries
	@fields12 = split(/\t/,$line);			# Get each of the 12 doublet entries

	my @samples = ();
	my @primers = ();

	print LAYOUT "<tr class=\"even\">\t";

	print LAYOUT "<td>" . $well{$wellNumber++} . "</td>\t";

	foreach $entry (@fields12) {			# For each doublet
		@subFields = split(/[+]/,$entry);	# Get the subfields
		push(@samples, $subFields[0]);
		push(@primers, $subFields[1]);
		}

	foreach $sample (@samples) {			# Add the samples to the first row
		chomp $sample;
		print LAYOUT "<td>" . $sample . "</td>";
		}

	print LAYOUT "</tr>\n";
	print LAYOUT "<tr class=\"odd\">\t";

	print LAYOUT "<td>&nbsp</td>";
	
	foreach $primer (@primers) {			# Add the primers to the second row
		chomp $primer;
		print LAYOUT "<td>" . $primer . "</td>";
		}
	print LAYOUT "</tr>\n";
	}

print LAYOUT "</table></body></html>";
close LAYOUT;

print " done!<br/>";

print ("Deleting <b>$plateID" . "_Layout.tmp</b> ...");
unlink("../SEQUENCING/output/$plateID" . "_Layout.tmp");
print "done!<br/>";

print ("Emailing plate layouts to <b>$email</b> (And cc-ing zbrumme@sfu.ca) ...");


use MIME::Lite;
use Net::SMTP;

my $destination = $email;
my $cc = 'zbrumme@sfu.ca';
my $subject = "PLATE LAYOUT: $plateID";
my $mainText = "User: $userName\nPlateID: $plateID\n\nThis is an automatically generated email, please do not respond!";
my $pltPath = "../SEQUENCING/output/$plateID" .".plt";
my $pltName = $plateID . ".plt";
my $layoutPath = "../SEQUENCING/output/$plateID" ."_Layout.html";
my $layoutName = $plateID . ".html";


$msg = MIME::Lite->new( From => 'plate.layout.designer@sfu.ca', To => $destination, Cc => $cc, Subject => $subject, Type => 'multipart/mixed', );
$msg->attach( Type => 'TEXT', Data => $mainText );
$msg->attach( Type => 'application/zip', Path => $pltPath,Filename => $pltName,Disposition => 'attachment' );
$msg->attach( Type => 'application/zip', Path => $layoutPath, Filename => $layoutName, Disposition => 'attachment' );
$msg->send('smtp','mailhost.sfu.ca', Debug=>0 );

print "done!<br/>";

# Files that are more than 30 days old go to the "archived" directory.
print "Archiving old files (<b>> 30 days old</b>) ...";
my $oldFiles = `find /Users/B_Team_iMac/Sites/SEQUENCING/output/* -mtime +30`;
system("mv `find /Users/B_Team_iMac/Sites/SEQUENCING/output/* -mtime +30` /Users/B_Team_iMac/Sites/SEQUENCING/output/Archived_Layouts/");

print 'done!<br/><br/>Redirecting...';
print '</body></html>';
