module Main where

import System.FSEvents
import Control.Concurrent

seconds = (* 1000000)

main = do
  ref <- startEventStream ["/"] $ \p -> do
    putStrLn $ "OMG WE GOT SOMETHING"
    putStrLn p
  threadDelay $ seconds 15
  stopEventStream ref
