module Main

import Data.String as S
import Control.ANSI as A
import Control.ANSI.SGR as A

main : IO ()
main = do 
  putStrLn $ "\n# " ++ show (A.colored A.Blue $ "Welcome to Idris") ++ "\n"
  putStrLn $ S.indent 4 $ show $ A.colored A.Green "Hello World"
