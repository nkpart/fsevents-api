{-# LANGUAGE ForeignFunctionInterface, EmptyDataDecls #-}
module System.FSEvents (
    EventStream,
    startEventStream,
    stopEventStream
    ) where

import Foreign.C
import Foreign.C.String
import Foreign.Ptr
import Foreign.Marshal.Alloc (free)
import Foreign.Marshal.Array
import Control.Monad (forM)

data EventStream = EventStream CEventStreamRef (FunPtr PathEvent)

data CEventStream
type CEventStreamRef = Ptr CEventStream

type PathEvent = CString -> IO ()
foreign import ccall "wrapper" mkPathEvent :: PathEvent -> IO (FunPtr PathEvent)

foreign import ccall unsafe 
    "Watcher.h WatcherCreate" 
    c_WatcherCreate :: Ptr CString -> CInt -> FunPtr (CString -> IO ()) -> IO CEventStreamRef

foreign import ccall unsafe 
    "Watcher.h WatcherRelease" 
    c_WatcherRelease :: CEventStreamRef -> IO ()

startEventStream :: [FilePath] -> (FilePath -> IO ()) -> IO EventStream
startEventStream paths f = do
  cStrs <- mapM newCString paths  
  callback <- mkPathEvent $ \c -> peekCString c >>= f
  watcher <- withArrayLen cStrs $ \count pp -> do
    c_WatcherCreate pp (fromIntegral count) callback
  mapM_ free cStrs
  return $ EventStream watcher callback

stopEventStream :: EventStream -> IO ()
stopEventStream (EventStream ref fp) = do
  c_WatcherRelease ref
  freeHaskellFunPtr fp

