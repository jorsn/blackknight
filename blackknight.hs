module Main
	where
import Prelude hiding (getLine)
import System.Exit
import System.IO hiding (getLine)
import System.Environment
import System.Posix.Signals
import System.Posix.PAM
import System.Posix.Unistd

import Control.Exception

clearInputBuffer = clear =<< hReady stdin
	where clear True  = getChar >> clearInputBuffer
	      clear False = return ()

getLineBuffered :: String -> IO String
getLineBuffered "\n" = return ""
getLineBuffered ('\n':xs) = return $ reverse xs
getLineBuffered "" = do
	c <- getChar
	getLineBuffered [c]
getLineBuffered "\DEL" = getLineBuffered ""
getLineBuffered ('\DEL':[x]) = getLineBuffered ""
getLineBuffered ('\DEL':x:xs) = getLineBuffered xs
getLineBuffered xs = do
	c <- getChar
	getLineBuffered (c:xs)

getLine =  getLineBuffered ""


check i e | e == Right () = exitSuccess
	  | i > 2    	  = putStrLn "None shall pass!" >> usleep 2000000 >> clearInputBuffer >> auth 0
          | otherwise     = putStrLn "Sorry, wrong password!" >> usleep 500000 >> clearInputBuffer >> auth i

auth i = do
       user <- getEnv "USER"
       putStr "Password: "
       hFlush stdout
       pw <- getLine
       putStrLn ""
       corr <- authenticate "blackknight" user pw
       check (i+1) corr

main = do
	blockSignals fullSignalSet
	hSetBuffering stdin NoBuffering
	hSetEcho stdin False
	clearInputBuffer
	auth 0
