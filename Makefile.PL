use ExtUtils::MakeMaker;

WriteMakefile (
	NAME			=> 'cmail',
	VERSION_FROM	=> 'cmail',
	ABSTRACT		=> 'a modular mail checker',
	AUTHOR			=> 'Chip Marshall <chip@chocobo.cx>',
	EXE_FILES		=> ['cmail'],
	PMLIBDIRS		=> ['CMail'],
	dist			=> {
		COMPRESS	=> 'bzip2 -fv',
		SUFFIX		=> '.bz2',
	},
);
