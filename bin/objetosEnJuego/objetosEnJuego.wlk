import wollok.game.*

import items.consumibles.*
import items.recursos.*
import items.materiales.*

import objetosEnJuego.imagenEnlazada.*

/******************** Objeto En Juegos ********************/
class ObjetoEnJuego
{
	method image()
	method interactuarCon(interactor) {}
	
	method quemar(quemador, gravedad) {}
	method desangrar(gravedad) {}
	method escarchar(gravedad) {}
	method congelar(gravedad) {}
	method cegar(gravedad) {}
	method sufrirDanio(danio, agresor) {}
	method recibirAtaqueDeHabilidad(danio, agresor) {}
	
	method agarrarItem(item) {}
	method esAtravesable() = true
}

