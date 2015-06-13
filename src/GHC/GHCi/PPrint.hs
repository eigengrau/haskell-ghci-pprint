{-# LANGUAGE UnicodeSyntax             #-}
{-# LANGUAGE FlexibleContexts          #-}
{-# LANGUAGE NoMonomorphismRestriction #-}

module GHC.GHCi.PPrint (myPrint, myShow, myUnescape) where

-- Colorize ghci output.

-- Based on code posted to:
-- http://www.reddit.com/r/haskell/comments/144biy/pretty_output_in_ghci_howto_in_comments
-- With additions to unescape Unicode characters in string literals.


import Prelude.Unicode

import qualified IPPrint
import qualified Language.Haskell.HsColour           as HsColour
import qualified Language.Haskell.HsColour.Colourise as HsColour
import qualified Language.Haskell.HsColour.Output    as HsColour

import Text.Regex.PCRE

myColourPrefs ∷ HsColour.ColourPrefs
myColourPrefs = HsColour.defaultColourPrefs {
                  HsColour.conid    = [HsColour.Foreground HsColour.Yellow, HsColour.Bold],
                  HsColour.conop    = [HsColour.Foreground HsColour.Yellow               ],
                  HsColour.string   = [HsColour.Foreground HsColour.Green                ],
                  HsColour.char     = [HsColour.Foreground HsColour.Cyan                 ],
                  HsColour.number   = [HsColour.Foreground HsColour.Red,    HsColour.Bold],
                  HsColour.layout   = [HsColour.Foreground HsColour.White                ],
                  HsColour.keyglyph = [HsColour.Foreground HsColour.White                ]
                }

myColorize ∷ String → String
myColorize = HsColour.hscolour
               (HsColour.TTYg HsColour.XTerm256Compatible)
               myColourPrefs
               False
               False
               ""
               False

myPrint ∷ Show α ⇒ α → IO ()
myPrint = putStrLn ∘ myColorize ∘ myShow

myShow ∷ Show α ⇒ α → String
myShow = myUnescape ∘ IPPrint.pshow

-- Unescapes escaped unicode chars.
myUnescape ∷ String → String
myUnescape = (concatMap unescapeToken) ∘ myTokenize

myTokenize ∷ String → [String]
myTokenize = getAllTextMatches ∘ matchToken

unescapeToken ∷ String → String
unescapeToken token
    | matchEscaped token = read $ ("\"") ⧺ token ⧺ ("\"")
    | otherwise          = token

normalRe, escapedRe, tokenRe ∷ String
normalRe     = ".|\n"
escapedRe    = "(\\\\[[:digit:]]+)"
tokenRe      = escapedRe ⧺ "|" ⧺ normalRe

matchEscaped, matchToken ∷ RegexContext Regex source target ⇒ source → target
matchEscaped = (=~ escapedRe)
matchToken   = (=~ tokenRe)
