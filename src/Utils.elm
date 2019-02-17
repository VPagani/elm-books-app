module Utils exposing (quif)

{-| A quick if
-}


quif : Bool -> a -> a -> a
quif condition branchTrue branchFalse =
    if condition then
        branchTrue

    else
        branchFalse
