import Distribution.Simple

import System.Directory
import System.Posix.Types
import System.Posix.Files
import Numeric

main = defaultMainWithHooks simpleUserHooks {
	postInst = cpconfig
}

pamdir = "/etc/pam.d/"
name = "blackknight"

srcpam = "./pam.d/" ++ name
destpam = pamdir ++ name

getOct s = filter $ readOct s
	where filter ((i, a):_) = i

cpconfig _ _ _ _ = doCP =<< fileExist destpam 
	where doCP False = do
		putStrLn $ "Copying " ++ srcpam ++ " to " ++ destpam ++ "."
		createDirectoryIfMissing True pamdir
		copyFile srcpam destpam
		putStrLn $ "Setting permissions for " ++ destpam ++ " to 0644."
		setFileMode destpam $ CMode $ getOct "0644"
	      doCP True = return ()
