module Main where

import FSEvents
import Control.Concurrent

main = do
  watchPaths ["/"]
  threadDelay 15000000
