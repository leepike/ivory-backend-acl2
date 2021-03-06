-- | Tests of the CPS and RTL IRs.
module Main (main) where

import Ivory.Compile.ACL2.ACL2Convert
import Ivory.Compile.ACL2.RTL
import Ivory.Language.Syntax.AST (ExpOp)

main :: IO ()
main = do
  writeFile "test.lisp" $ unlines $ map show $ acl2Convert rtl

rtl :: Program ExpOp
rtl = snd $ elaborate () $ do
  label "start"
  pushCont "done"
  const' 1 "one"
  branch "one" "here"
  fail'
  label "here"
  return'      -- XXX This causes ACL2 to fail.  Same problem in fac test.
  label "done"
  halt

