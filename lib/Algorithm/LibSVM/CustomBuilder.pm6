use LibraryMake;
use Distribution::Builder::MakeFromJSON;

class Algorithm::LibSVM::CustomBuilder:auth<zef:titsuki>:ver<0.0.18> is Distribution::Builder::MakeFromJSON {
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

	my constant $VERSION = "3.25";
	if $VERSION.IO.d {
	    # Workaround for build issue on OSX
	    my $p = Proc::Async.new("echo", "-n");
	    $p.stdout.tap(-> $v { });
	    await $p.start;
	    shell "patch $VERSION/svm.h $VERSION/svm.h.patch -o svm.h";
	    shell "patch $VERSION/svm.cpp $VERSION/svm.cpp.patch -o svm.cpp";
	}
	shell(%vars<MAKE>);
	chdir($goback);
    }
}
