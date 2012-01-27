module Main where

import System.FSEvents
import Control.Concurrent

main = do
  ref <- startEventStream ["/"] $ \p -> do
    putStrLn $ "OMG WE GOT SOMETHING"
    putStrLn p
  threadDelay 15000000
  stopEventStream ref
