import Distribution.Simple
import Distribution.Simple.LocalBuildInfo
import Distribution.Simple.Utils
import Distribution.Verbosity

main = defaultMainWithHooks simpleUserHooks {
	postInst = cpconfig
}

name = "blackknight"

pamdir = "/etc/pam.d/"
srcpam = "./pam.d/" ++ name
destpam = pamdir ++ name

cpconfig _ _ _ info = do
	createDirectoryIfMissingVerbose verbose True pamdir
	installOrdinaryFile verbose srcpam destpam
	installOrdinaryFile verbose "README.md" $
		(fromPathTemplate (docdir $ installDirTemplates info))
		++ "/README.md"
