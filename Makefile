convert_stepmod_repo:
	bundle exec ./exe/stepmod-annotate-all $(10303_stepmod_path)

create_svgs:
	java -jar $(stepmod2mn_jar_path) $(10303_stepmod_path) -svg