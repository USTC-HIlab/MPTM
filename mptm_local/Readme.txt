MPTM Lite Package: A TOOL FOR MINING POST-TRANSLATIONAL MODIFICATION FROM LITERATURE
Virsion 1.0 (Sep 2016)

============================================================================================================

Dongdong Sun(sddchina@mail.ustc.edu.cn)
School of Information Science and Technology,University of Science and Technology of China,Hefei AH230027,China
AoLi (aoli@ustc.edu.cn)
School of Information Science and Technology,University of Science and Technology of China,Hefei AH230027,China



=============================================================================================================

COMPILING THE CODE

=============================================================================================================

First, make sure you have the following tools installed and working:

  o  Java SDK 1.7 - http://java.sun.com/j2ee/download.html
  o  Perl  5.x  - http://www.perl.org/get.html
  o  LWP package - http://search.cpan.org/~mschilli/libwww-perl-6.08/lib/LWP.pm

and your network is available because the tool will download abstract from PubMed.
 
Next, you will need to change into the root driectory (mptm/bin/ directory).After that, 
information extract and output the results with the command:

Windows:
perl mptm_windows.pl ../example/inputpmids.txt ../example/results.txt

Linux:
use lingpipe
perl mptm_linux.pl ../example/inputpmids.txt ../example/results.txt

use banner
perl mptm_linux_banner.pl ../example/inputpmids.txt ../example/results.txt

=============================================================================================================

We encourage you to contact us via: Dongdong Sun sddchina@mail.ustc.edu.cn

Thank you.



