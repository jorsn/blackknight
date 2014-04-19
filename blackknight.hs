{-# LANGUAGE BangPatterns #-}
module Main
       where
import Prelude hiding (getLine)

import qualified Data.ByteString.Lazy as B
import Data.List

import System.Exit
import System.IO hiding (getLine)
import System.Environment

import System.Posix.IO
import System.Posix.Signals
import System.Posix.PAM
import System.Posix.Unistd
import System.Posix.Terminal


data VCSA = NoVCSA | VCSA { vcsaPath :: FilePath, vcsaData :: B.ByteString }

getVcsa lockh tty = do
        let vPath = "/dev/vcsa" ++ [last tty]
        !vData <- B.readFile vPath
        return $ lockh { vcsa = (VCSA vPath vData) }

restoreVcsa (LockHandle (VCSA vPath vData) _ _) = B.writeFile vPath vData
restoreVcsa (LockHandle _ _ _)                  = return ()


data LockHandle = LockHandle {
        vcsa  :: VCSA,
        user  :: String,
        tries :: Int
}
defaultIOLockHandle = getEnv "USER" >>= \u -> return $ LockHandle NoVCSA u 0

data Settings = Settings { clear :: Bool, msg :: Maybe String }

defaultIOSettings lockh = do
        tty <- getTerminalName stdInput
        return $ Settings True $ Just $ (drop 5 tty) ++ " locked by " ++ user lockh ++ "."

help = putStrLn $
        "\ESC[1mUsage:\ESC[0m   blackknight [-h|--help]\n"
                   ++ "         blackknight [-nc|--noclear] [-nm|--nomsg]"
                              ++ " [\ESC[4malternate lock message\ESC[0m]"

        

clearInputBuffer = clear =<< hReady stdin
        where clear True  = getChar >> clearInputBuffer
              clear False = return ()

getLineBuffered :: String -> IO String
getLineBuffered "\n"          = return ""
getLineBuffered ('\n':xs)     = return $ reverse xs
getLineBuffered ""            = do
        c <- getChar
        getLineBuffered [c]
getLineBuffered "\DEL"        = getLineBuffered ""
getLineBuffered ('\DEL':[x])  = getLineBuffered ""
getLineBuffered ('\DEL':x:xs) = getLineBuffered xs
getLineBuffered xs            = do
        c <- getChar
        getLineBuffered (c:xs)


getLine =  getLineBuffered ""


check lockh e | e == Right ()     = return ()
              | (tries lockh) > 2 = putStrLn "None shall pass!"       >> usleep 2000000
                                    >> clearInputBuffer >> auth (lockh { tries = 0 })
              | otherwise         = putStrLn "Sorry, wrong password!" >> usleep  500000
                                    >> clearInputBuffer >> auth (lockh { tries = (tries lockh + 1) })

auth lockh = do
       putStr "Password: "
       hFlush stdout
       pw <- getLine
       putStrLn ""
       corr <- authenticate "blackknight" (user lockh) pw
       check lockh corr



clearScreen lockh b = getTerminalName stdInput >>= \tty ->
        if b && "tty" `isInfixOf` tty then do
                lockh' <- getVcsa lockh tty
                putStr "\ESC[H\ESC[2J"
                return lockh'
        else return $ lockh { vcsa = NoVCSA }

printMsg (Just m) = putStrLn m
printMsg Nothing  = return ()

handleSettings lockh (Settings b m) = clearScreen lockh b >>= \lockh' -> printMsg m >> return lockh'

handleArgs :: LockHandle -> [String] -> Settings -> IO LockHandle
handleArgs lockh []     ds = handleSettings lockh ds
handleArgs lockh (a:as) ds | (a == "-h"  || a == "--help")    = help >> exitSuccess
                           | (a == "-nc" || a == "--noclear") = handleArgs lockh as $ ds { clear = False }
                           | (a == "-nm" || a == "--nomsg")   = handleArgs lockh as $ ds { msg  = Nothing }
                           | otherwise                        = handleSettings lockh $ ds { msg = (Just a) }

main :: IO ()
main = do
        blockSignals fullSignalSet
        hSetBuffering stdin NoBuffering
        hSetEcho stdin False
        args <- getArgs
        lockh <- defaultIOLockHandle
        lockh' <- (handleArgs lockh args) =<< defaultIOSettings lockh
        clearInputBuffer
        auth lockh'
        restoreVcsa lockh'

-- vim: expandtab
