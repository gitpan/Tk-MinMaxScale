#! /usr/bin/perl -w
use strict;
use diagnostics;
use Tk;
use Tk::MinMaxScale;

# version avec closures
# point crees une fois pour toutes

package main;
# les widgets et les variables associees
use vars qw/
	$top
		$fh
 			$fhg
 				$nbda
 				$vaMax $aMaxMax $aMaxDefaut
 				$vaMin $aMinMin $aMinDefaut
			$fhm
 				$labela
 				$labelb
			$fhd
				$nbdb
 				$vbMax $bMaxMax $bMaxDefaut
 				$vbMin $bMinMin $bMinDefaut
		$canvas
 		$fb
 			$vdelai $delaiDefaut
 			$vnbPointsAvantChangement $nbPointsDefaut
	/;

# les "globales"
use vars qw/$a $b	$c $x $y $oldx $w/;

my $debug = 0;		# 1 = imprime le nb de points
my $nbpaff = 0;		# nombre de points affichés
my $nbpcalc = 0;	# nombre de points calculés

# le canevas d'affichage
my $couleurBlanc = '#ffffff';
my $couleurPoint = randomColor();
my $couleurFond = '#ffffc0';
my $nbPoints;
my @objets = ();
my $meilleurRapport = 128;

# centre du canevas
my ($cx, $cy);
	
# valeurs extremes pour les curseurs a et b		
$aMinMin = 0.0;
$aMaxMax = 1.0;
$bMinMin = 0.9990;
$bMaxMax = 1.0;

# valeurs par defaut des curseurs a et b
$aMinDefaut = 0.5590;	# aMin
$aMaxDefaut = 0.5591;	# aMax
$bMinDefaut = 0.9998;	# bMin
$bMaxDefaut = 0.9999;	# bMax

# nombre de digits pour a et b
$nbda = 5;
$nbdb = 5;
$delaiDefaut = 5;			# intervalle de rafraichissement (secondes)
$nbPointsDefaut = 512;		# nombre de points consecutifs de meme couleur

srand;
init();
MainLoop;

sub init {
	# definitions
	my @bg = ('-bg', $couleurFond);
	my @commonCur = (@bg, qw/-orient h/);
	my @commonfp = qw/-anchor w -fill x/;
	my @packdefst = qw/-expand 1 -fill x -side top/;
	my @packdefsl = qw/-expand 1 -fill x -side left/;

	# fenetre maitre
	$top = new MainWindow(@bg, -title => 'Orbites de Mira & Gumowski');

	# cadre du haut
	$fh = $top->Frame(@bg)->pack(@commonfp);
	# la zone de dessin
	$canvas = $top->Canvas(-bg => $couleurBlanc, -width => 450, -height => 450)->pack(-anchor => 'w', -expand => 1, -fill => 'both', -padx => 2, -pady => 2);
	# cadre du bas
	$fb = $top->Frame(@bg)->pack(@commonfp);

	# cadre en haut a gauche
	$fhg = $fh->Frame(@bg)->pack(@packdefsl);
	# cadre en haut au milieu
	$fhm = $fh->Frame(@bg)->pack(@packdefsl);
	# cadre en haut a droite
	$fhd = $fh->Frame(@bg)->pack(@packdefsl);

	# cadre en haut a gauche : curseurs a min et a max
	creerCurseursMinMax('a min / max', \$fhg, $nbda, $aMinMin, $aMaxMax, \$vaMin, \$vaMax, @commonCur);

	# cadre en haut, au milieu : valeurs actuelles de a et b
	$labela = $fhm->Label(@bg)->pack(@packdefst);
	$labelb = $fhm->Label(@bg)->pack(@packdefst);

	# cadre en haut a droite : curseur b min et b max
	creerCurseursMinMax('b min / max', \$fhd, $nbdb, $bMinMin, $bMaxMax, \$vbMin, \$vbMax, @commonCur);

	# cadre du bas : curseur delai rafraichissement
	$fb->Scale(@commonCur,
		-label => 'rafraîchissement (secondes)',
		-digits => 3,
		-from => 1,
		-to => 240,
		-variable => \$vdelai,
		-bigincrement => 10,
	)->pack(@packdefsl);

	# cadre du bas : curseur nombre de points de meme couleur
  $fb->Scale(@commonCur,
		-label => 'points consécutifs de même couleur',
		-digits => 4,
		-from => 1,
		-to => 4096,
		-variable => \$vnbPointsAvantChangement,
		-bigincrement => 16,
	)->pack(@packdefsl);

	# valeurs initiales des variables
	$vaMin = $aMinDefaut;
	$vaMax = $aMaxDefaut;
	$vbMin = $bMinDefaut;
	$vbMax = $bMaxDefaut;
	$vdelai = $delaiDefaut;
	$vnbPointsAvantChangement = $nbPointsDefaut;
	# ajustement des curseurs
	redimensionner(0, $canvas->cget('-width'), $canvas->cget('-height'));
	$canvas->Tk::bind("<Configure>",[\&redimensionner, Ev('w'), Ev('h')]);

	nouvelleOrbite(); # initialisation de la premiere orbite
	$top->after(1, \&nouveauxPoints); # c'est parti !
}

sub creerCurseursMinMax {
	my @packdefst = qw/-expand 1 -fill x -side top/;
	my ($label, $frame, $nbd, $min, $max, $varn, $varx, @commun) = @_;
	$$frame->MinMaxScale(
		@commun,
		-labelmin => $label,
		-digits => $nbd,
		-resolution	 => 10**(1-$nbd),
		-from => $min,
		-to => $max,
		-variablemin => $varn,
		-variablemax => $varx,
		-bigincrement => 0.1,
	)->pack(-expand => 1, -fill => 'x', -side => 'top');
}

# gestion du redimensionnement de la fenetre
sub redimensionner {
	# effacer
	razCanevas();
	# nouvelles coordonnees du centre
	my ($x, $w, $h) = @_;
	$cx = $w/2;
	$cy = $h/2;
}

#------------------------------------------------------------
# changement des parametres a et b tous les $vdelai secondes
#------------------------------------------------------------
sub nouvelleOrbite {
	if ($debug) { print "c:$nbpcalc/a:$nbpaff/o:", 0+@objets; }
	razCanevas();
	if ($debug) { print " raz:", 0+@objets, "\n"; }

	# calcul d'un nouveau couple [a,b]
	$a = $vaMin + ($vaMax - $vaMin) * rand();
	$c = 2 * (1 - $a);
	$labela->configure(-text => sprintf("a = %.15f", $a));

	$b = $vbMin + ($vbMax - $vbMin) * rand();
	$labelb->configure(-text => sprintf("b = %.15f", $b));

	# valeurs initiales x et y adaptees aux dimensions du canevas
	# les valeurs exactes ont peu d'importance
	$x = $cx/2;
	$y = $cy/2;

	$nbPoints = $vnbPointsAvantChangement;

	# relance
	$top->after($vdelai*1000, \&nouvelleOrbite);
}

#----------------------
# le coeur de la chose
#----------------------
sub nouveauxPoints {
# Orbites de Mira & Gumowski
# reference : Hans Lauwerier - Fractals, images of chaos - Penguin book (UK, 1991)
# a, b constantes pour une orbite
#   c = 2 * (1 - a)
#   x[n] = b*y[n-1] + a*x[n-1] + c*x[n-1]*x[n-1]/(1+x[n-1]*x[n-1])
#   y[n] = a*x[n] + c*x[n]/(1+x[n]) - x[n-1]
#
# soit, en posant : w[n] = a*x[n] + c*x[n]*x[n]/(1+x[n]*x[n])
#
# x[n] = b*y[n-1] + w[n-1] (la nouvelle abscisse depend de l'abscisse et de l'ordonnee du point precedent)
# y[n] = w[n] - x[n-1]		 (la nouvelle ordonnee depend des abscisses des points actuel et precedent)

for (my $i = 0; $i < $meilleurRapport; $i++) {
	# calcul du point suivant
	$oldx = $x;                        		# x[n-1]
	$w = $a * $x + $c * $x / ($x + 1); 		# w[n-1]
	$x = $b * $y + $w;                    # x[n]
	$w = $a * $x + $c * $x / ($x + 1);    # w[n]
	$y = $w - $oldx;                      # y[n]
	$nbpcalc++;
	# affichage du nouveau point
	if ((abs($x) < $cx) && (abs($y) < $cy)) {
		my $affx = $cx + $x;
		my $affy = $cy + $y;

		# creation d'un nouveau point
		# pas mieux que createRectangle, createLine ou createOval pour afficher un pixel
		if ($nbpaff >= 0+@objets) {
			if (!($nbpaff % $vnbPointsAvantChangement)) {	$couleurPoint = randomColor(); }
#			push(@objets, $canvas->createRectangle(-1, -1, -1, -1, -outline => $couleurPoint));
#			push(@objets, $canvas->createOval(-1, -1, -1, -1, -outline => $couleurPoint));
			push(@objets, $canvas->createLine(-1, -1, 0, 0, -fill => $couleurPoint));
		}
		# deplacement d'un point, nouvellement cree ou non
		$canvas->move($objets[$nbpaff], $affx, $affy);
		$nbpaff++;
  }
}
	$top->after(1, \&nouveauxPoints);
}

# effacer le canvas
sub razCanevas {
	# ramener $objets à une taille raisonnable
	if ($nbpaff < @objets) {
		$canvas->delete(splice(@objets, ($nbpaff+@objets)/2));
	}
	# masquer les points
	#$canvas->coords('all', -1, -1, -1, -1); # non ! ? ! ne masque que le premier ?
	for (my $n = 0; $n < 0+@objets; $n++) {
		if (!($n % $vnbPointsAvantChangement)) {	$couleurPoint = randomColor(); }

		# si Line
		$canvas->coords($objets[$n], -1, -1, 0, 0);
		$canvas->itemconfigure($objets[$n], -fill => $couleurPoint);

		# si Rectangle ou Oval
		#$canvas->coords($objets[$n], -1, -1, -1, -1);
		#$canvas->itemconfigure($objets[$n], -outline => $couleurPoint);
	}
	$nbpaff = 0;
	$nbpcalc = 0;
}

#-------------------
# couleur au hasard
#-------------------
sub randomColor {
	my $quartet = 2; # 1=#rvb, 2 = #rrvvbb, 3 = #rrrvvvbbb etc.
	my $def = 4*$quartet;
	return 	'#'.sprintf("%0$quartet.0x", rand(2**$def))
						 .sprintf("%0$quartet.0x", rand(2**$def))
						 .sprintf("%0$quartet.0x", rand(2**$def));
}
__END__	
