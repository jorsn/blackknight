module Main
	where
--import GHC.IO.Handle

import System.Exit
import System.IO
import System.Environment
import System.Posix.Signals
import System.Posix.PAM
import System.Posix.Unistd

import Control.Exception

clearInputBuffer = clear =<< hReady stdin
	where clear True  = getChar >> clearInputBuffer
	      clear False = return ()

safeGetLine :: IO String
safeGetLine = catch (getLine) (\e -> do let err = (e :: IOException)
					return "")

check i e | e == Right () = exitSuccess
	  | i > 2    	  = putStrLn "None shall pass!" >> usleep 2000000 >> clearInputBuffer >> auth 0
          | otherwise     = putStrLn "Sorry, wrong password!" >> auth i

auth i = do
       user <- getEnv "USER"
       putStr "Password: "
       hFlush stdout
       pw <- safeGetLine
       putStrLn ""
       corr <- authenticate "blackknight" user pw
       check (i+1) corr

main = do
	blockSignals fullSignalSet
	hSetBuffering stdin LineBuffering
	hSetEcho stdin False
	auth 0
