use LibraryMake;
use Distribution::Builder::MakeFromJSON;

class Algorithm::LibSVM::CustomBuilder:ver<0.0.7> is Distribution::Builder::MakeFromJSON {
    method build(IO() $work-dir = $*CWD) {
        my $workdir = ~$work-dir;
	my $srcdir = "$workdir/src";
	my %vars = get-vars($workdir);
	%vars<svm> = $*VM.platform-library-name('svm'.IO);
	mkdir "$workdir/resources" unless "$workdir/resources".IO.e;
	mkdir "$workdir/resources/libraries" unless "$workdir/resources/libraries".IO.e;
	process-makefile($srcdir, %vars);
	my $goback = $*CWD;
	chdir($srcdir);

	my constant $VERSION = "3.22";
	if $VERSION.IO.d {
	    shell "patch $VERSION/svm.h $VERSION/svm.h.patch -o svm.h";
	    shell "patch $VERSION/svm.cpp $VERSION/svm.cpp.patch -o svm.cpp";
	}
	shell(%vars<MAKE>);
	chdir($goback);
    }
}
