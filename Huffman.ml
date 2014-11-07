(**********************************************
        Projet OCAML S5

  Auteurs : Luxon JEAN-PIERRE & Kahina RAHANI

 **********************************************)

(***********************************************************
  Fichier : Huffman.ml

  Definition des fonctions de gestion de l'arbre de Huffman
 ***********************************************************)


#use "Histogramme.ml";;

(* Type Arbre de Huffman*)

type arbreH = 
  | Nil
  | Feuille of histo
  | Node of int * arbreH * arbreH;;


(* Fonction insert_tree *)

let rec insert_tree a l = match l with
  | [] -> [a]
  | t::q -> (match a, t with 
      | Nil, Nil -> q 
      | Nil, t -> t::q
      | a, Nil -> insert_tree a q
      | Feuille(cpa), Feuille(cpt) -> (match cpa, cpt with
	  | Vide, Vide -> q
	  | Vide , cpt -> t::q
	  | cpa, Vide -> insert_tree a q  
	  | Couple(_,i1), Couple(_,i2) -> 
	    if i1 = i2 then a::t::q
	    else if i1 < i2 then a::t::q
	    else t ::(insert_tree a q))
      | Feuille(cpa), Node(n,_,_)-> (match cpa with
	  | Vide -> t::q
	  | Couple(_,i) -> 
	    if n = i then a::t::q 
	    else if n < i then t::(insert_tree a q)
	    else a::t::q)
      | Node(n,_,_), Feuille(cpt) -> (match cpt with 
	  | Vide -> insert_tree a q
	  | Couple(_, i) -> 
	    if i = n then a::t::q
	    else if n < i then a::t::q
	    else t::(insert_tree a q))
      | Node(n1,_,_) , Node(n2,_,_) -> 
	if n1 = n2 then a::t::q
	else if n1 < n2 then a::t::q
	else t::(insert_tree a q))
;;

(* Test *)

(*insert_tree Nil [];;
insert_tree (Feuille(Couple('t', 8))) [];;
insert_tree (Feuille(Couple('a', 4))) [Nil];;
insert_tree Nil [(Feuille(Couple('H', 2)))] ;;

insert_tree (Feuille(Vide)) [(Feuille(Vide))];;
insert_tree (Feuille(Vide)) [(Feuille(Couple('s', 1)))];;
insert_tree (Feuille(Couple('t', 1))) [(Feuille(Vide))];;

insert_tree (Feuille(Couple('t', 8))) [(Feuille(Couple('f', 3)))];;
insert_tree (Feuille(Couple('t', 2))) [(Feuille(Couple('f', 3)))];;

insert_tree (Feuille(Couple('t', 12))) [(Node(10,(Feuille(Couple('A', 7))),Feuille(Couple('t',3)) ))];;
insert_tree (Feuille(Vide)) [(Node(9,(Feuille(Couple('A', 7))),Feuille(Couple('t',3)) ))];;

insert_tree (Node(10,(Feuille(Couple('A', 7))),Feuille(Couple('t',3)) )) [(Feuille(Couple('t', 1)))];;
insert_tree (Node(10,(Feuille(Couple('A', 7))),Feuille(Couple('t',3)) )) [(Feuille(Vide))];;

insert_tree (Node(10,(Feuille(Couple('A', 7))),Feuille(Couple('t',3)) )) [(Node(12,(Feuille(Couple('A', 6))),Feuille(Couple('t',6)) ))];;*)


(* Fonction fusion *)
(* Réalise une union de 2 arbres*)
let fusion a1 a2= match a1,a2 with
  | Nil, Nil -> Nil
  | Nil, a2 -> a2
  | a1, Nil -> a1
  | Feuille(cp1) , Feuille(cp2) -> (match cp1,cp2 with
      | Vide,Vide -> Feuille(Vide)
      | Vide,cp2 -> Feuille(cp2)
      | cp1, Vide -> Feuille(cp1)
      | Couple(c1,i1),Couple(c2,i2) -> Node( (i1+i2) , Feuille(cp1), Feuille(cp2) ))
  | Feuille(cp1), Node(n,t1, t2) -> (match cp1 with
      | Vide -> a2
      | Couple(_, i1) -> Node((n + i1),a1,a2) )
  | Node(n, t1, t2), Feuille(cp2) -> (match cp2 with
      |Vide -> a1
      |Couple(_, i2) -> Node((n + i2),a1,a2))
  |Node(n1,g,Nil), Node(n2,_,_) -> Node( (n1 + n2), g,a2)
  |Node(n1,_,_) , Node(n2, _, _) -> Node( (n1 + n2), a1, a2)
;;


(* On convertit la liste d'histogramme en liste d'arbres (forêt) *)

let rec conversion_histoToArbre l_histo = match l_histo with
  | [] -> []
  | t::q -> Feuille(t)::(conversion_histoToArbre q);;


(* Fonction construire_Huffman *)

(* A partir de la liste d'arbres, on construit l'arbre de Huffman*)
let rec construire_Huffman = function
  | [] -> Nil
  | [t] -> (match t with
      | Nil -> failwith "Erreur : Arbre non valide"
      | Feuille(c) -> ( match c with
	  | Vide -> failwith " Erreur : Couple vide, non valide"
	  | Couple(a,b) ->  t)
      | Node(_,_,_) -> t )
  | t1::t2::q -> construire_Huffman(insert_tree (fusion t1 t2) q);;



(* On définit un type algébrique qui va stocker la lettre et son code associé *)

type codeCompress = Code of (char * int list);;

Code('a', [1;0]);;

exception Arbre_vide;;
exception Histo_vide;;

let construireCode arbre =
  let rec construireCode_aux arbre l_bit l_code = match arbre with
  | Nil -> []
  | Feuille f ->(match f with
      | Vide -> raise Histo_vide
      | Couple(c,_) -> Code(c, l_bit)::l_code )
  | Node(_,g,d) -> let lb = l_bit in let l_code_bis = construireCode_aux g (lb@[0]) l_code in
		   (l_code_bis@(construireCode_aux d (l_bit@[1]) l_code))
  in construireCode_aux arbre [] [];;

construireCode Nil;;
construireCode (Feuille(Couple('t', 8)));;


(*let texte = lire_fichier "data/abracadabra.txt";;
let histogramme = creer_histo texte (gen_list_occ (texte));;
let histogramme = insert_histo (Couple('\255',1)) histogramme;;
let sorted_histogramme = sort_histo histogramme;;
let liste_arbre =  conversion_histoToArbre sorted_histogramme;;
let huff_tree = construire_Huffman liste_arbre;;

let result = construireCode huff_tree;;*)
