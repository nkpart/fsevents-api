module Main where

import FSEvents
import Control.Concurrent

main = do
  startWatcher ["/"] $ \p -> do
    putStrLn $ "OMG WE GOT SOMETHING"
    putStrLn p
  threadDelay 15000000
