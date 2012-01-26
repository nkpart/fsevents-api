module FSEvents where

import Foreign.C
import Foreign.C.String
import Foreign.Ptr
import Foreign.Marshal.Alloc (free)
import Foreign.Marshal.Array
import Control.Monad (forM)

data Watcher
type WatcherRef = Ptr Watcher

foreign import ccall unsafe 
    "Watcher.h WatcherCreate" 
    c_WatcherCreate :: Ptr (Ptr CChar) -> CInt -> IO WatcherRef

foreign import ccall unsafe 
    "Watcher.h WatcherRelease" 
    c_WatcherRelease :: WatcherRef -> IO ()

watchPaths :: [String] -> IO WatcherRef
watchPaths paths = do
  print 1
  cStrs <- mapM newCString paths  
  print 2
  watcher <- withArrayLen cStrs $ \count pp -> c_WatcherCreate pp (fromIntegral count)
  print 3
  mapM_ free cStrs
  print 4
  return watcher

stopWatcher :: WatcherRef -> IO ()
stopWatcher = c_WatcherRelease

