#!/usr/bin/env runghc
module Main where
import System.Exit
import System.Environment
import Text.LineToPDF
import qualified Data.ByteString.Lazy.Char8 as L

main :: IO ()
main = do
    args <- getArgs

    (enc, input) <- case args of
        []      -> do
            putStrLn "Usage: ./big5-to-pdf.hs big5.txt > output.pdf"
            putStrLn "  (Form feed (^L) in input denotes a pagebreak.)"
            exitWith ExitSuccess
        (i:_)             -> return (Big5, i)

    src <- L.readFile input
    lineToPDF $ (defaultConfig enc src)
        { pageWidth  = 595
        , pageHeight = 842
        , ptSize     = 12.25
        }
