module FSEvents where

import Foreign.C
import Foreign.C.String
import Foreign.Ptr
import Foreign.Marshal.Alloc (free)
import Foreign.Marshal.Array
import Control.Monad (forM)

data CWatcher
type CWatcherRef = Ptr CWatcher

type PathEvent = CString -> IO ()

data Watcher = Watcher CWatcherRef (FunPtr PathEvent)

foreign import ccall "wrapper"
  mkPathEvent :: PathEvent -> IO (FunPtr PathEvent)

foreign import ccall unsafe 
    "Watcher.h WatcherCreate" 
    c_WatcherCreate :: Ptr CString -> CInt -> FunPtr (CString -> IO ()) -> IO CWatcherRef

foreign import ccall unsafe 
    "Watcher.h WatcherRelease" 
    c_WatcherRelease :: CWatcherRef -> IO ()

startWatcher :: [String] -> (String -> IO ()) -> IO Watcher
startWatcher paths f = do
  cStrs <- mapM newCString paths  
  callback <- mkPathEvent $ \c -> do
    path <- peekCString c
    f path
  watcher <- withArrayLen cStrs $ \count pp -> do
    c_WatcherCreate pp (fromIntegral count) callback
  mapM_ free cStrs
  return $ Watcher watcher callback

stopWatcher :: Watcher -> IO ()
stopWatcher (Watcher ref fp) = do
  c_WatcherRelease ref
  freeHaskellFunPtr fp

