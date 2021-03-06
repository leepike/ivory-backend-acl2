module Mira.Expr
  ( Var
  , Literal   (..)
  , Expr      (..)
  , Intrinsic (..)
  , encodeIntrinsic
  , intrinsicACL2
  , allIntrinsics
  , exprACL2
  , showLit
  ) where

import Data.Maybe (fromJust)
import Data.List
import Text.Printf

import Mira.ACL2 hiding (Expr)
import qualified Mira.ACL2 as A

type Var = String

-- | Literals.
data Literal
  = LitInteger Integer
  | LitFloat Float
  | LitDouble Double
  | LitChar Char
  | LitBool Bool
  | LitNull
  | LitString String
  deriving Eq

instance Show Literal where
  show a = case a of
    LitInteger a -> show a
    LitFloat   a -> show a
    LitDouble  a -> show a
    LitChar    a -> show a
    LitBool    a -> show a
    LitString  a -> show a
    LitNull      -> "null"

instance Num Literal where
  (+)    = error "Method not supported for Num Literal."
  (-)    = error "Method not supported for Num Literal."
  (*)    = error "Method not supported for Num Literal."
  negate = error "Method not supported for Num Literal."
  abs    = error "Method not supported for Num Literal."
  signum = error "Method not supported for Num Literal."
  fromInteger = LitInteger

data Expr
  = Var       Var
  | Literal   Literal
  | Intrinsic Intrinsic [Expr]

instance Show Expr where
  show a = case a of
    Var a -> a
    Literal a -> show a
    Intrinsic a args -> printf "%s(%s)" (show a) (intercalate ", " $ map show args)

data Intrinsic
  = Eq
  | Neq
  | Cond
  | Gt
  | Ge
  | Lt
  | Le
  | Not
  | And
  | Or
  | Mul
  | Mod
  | Add
  | Sub
  | Negate
  | Abs
  | Signum
  deriving (Show, Eq)

allIntrinsics :: [Intrinsic]
allIntrinsics =
  [ Eq
  , Neq
  , Cond
  , Gt
  , Ge
  , Lt
  , Le
  , Not
  , And
  , Or
  , Mul
  , Mod
  , Add
  , Sub
  , Negate
  , Abs
  , Signum
  ]

encodeIntrinsic :: Intrinsic -> Int
encodeIntrinsic a = fromJust $ elemIndex a allIntrinsics

intrinsicACL2 :: Intrinsic -> (Int -> A.Expr) -> A.Expr
intrinsicACL2 a arg = case a of
  Eq     -> if' (equal (arg 0) (arg 1)) 1 0
  Neq    -> if' (not' (equal (arg 0) (arg 1))) 1 0
  Cond   -> if' (zip' (arg 0)) (arg 2) (arg 1)
  Gt     -> if' (call ">"  [arg 0, arg 1]) 1 0
  Ge     -> if' (call ">=" [arg 0, arg 1]) 1 0
  Lt     -> if' (call "<"  [arg 0, arg 1]) 1 0
  Le     -> if' (call "<=" [arg 0, arg 1]) 1 0
  Not    -> if' (zip' (arg 0)) 1 0
  And    -> if' (or'  (zip' (arg 0)) (zip' (arg 1))) 0 1
  Or     -> if' (and' (zip' (arg 0)) (zip' (arg 1))) 0 1
  Mul    -> arg 0 * arg 1
  Mod    -> mod' (arg 0) (arg 1) 
  Add    -> arg 0 + arg 1
  Sub    -> arg 0 - arg 1
  Negate -> 0 - arg 0
  Abs    -> if' (call ">=" [arg 0, 0]) (arg 0) (0 - arg 0)
  Signum -> if' (call ">"  [arg 0, 0]) 1 $ if' (call "<" [arg 0, 0]) (-1) 0

exprACL2 :: Expr -> A.Expr
exprACL2 a = case a of
  Var a -> var a
  Literal a -> lit $ showLit a
  Intrinsic i args -> intrinsicACL2 i (map exprACL2 args !!)

showLit :: Literal -> String
showLit a = case a of
  LitInteger a -> show a
  LitBool    True  -> "1"
  LitBool    False -> "0"
  a -> error $ "unsupported literal: " ++ show a

