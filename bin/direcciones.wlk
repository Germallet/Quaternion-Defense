import wollok.game.*

object arriba
{
	override method toString() = "Arriba"
	
	method opuesta() = abajo
	
	method ortogonales() = [izquierda, derecha]
	
	method posicion(posicion) = posicion.up(1)
	
	method posicion(posicion, n) = posicion.up(n)
}
object abajo  
{
	override method toString() = "Abajo"
	
	method opuesta() = arriba
	
	method ortogonales() = [izquierda, derecha]
	
	method posicion(posicion) = posicion.down(1)
	
	method posicion(posicion, n) = posicion.down(n)
}
object izquierda  
{
	override method toString() = "Izquierda"
	
	method opuesta() = derecha
	
	method ortogonales() = [abajo, arriba]
	
	method posicion(posicion) = posicion.left(1)
	
	 method posicion(posicion, n) = posicion.left(n)
}
object derecha  
{
	override method toString() = "Derecha"
	
	method opuesta() = izquierda

	method ortogonales() = [abajo, arriba]
	
	method posicion(posicion) = posicion.right(1)
	
	method posicion(posicion, n) = posicion.right(n)
}

class Diagonal 
{
	const property horizontal
	const property vertical
	
	constructor(_horizontal, _vertical)
	{
		horizontal = _horizontal
		vertical = _vertical
	}
	
	method posicion(posicion) = vertical.posicion(horizontal.posicion(posicion))
	
	method posicion(posicion, n) = vertical.posicion(horizontal.posicion(posicion, n), n)
	
	method opuesta() = new Diagonal(horizontal.opuesta(), vertical.opuesta())
	
	method ortogonales() = [new Diagonal(horizontal, vertical.opuesta()), new Diagonal(horizontal.opuesta(), vertical)]
	
	override method ==(diagonal) = diagonal.horizontal() == horizontal and diagonal.vertical() == vertical
}
