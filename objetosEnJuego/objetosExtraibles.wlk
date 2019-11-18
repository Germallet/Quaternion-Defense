import wollok.game.*

import objetosEnJuego.objetosDeInteraccion.*

import items.recursos.*
import items.consumibles.*
import items.materiales.*

import probabilidad.*

/******************** Objetos Extraibles ********************/
class ObjetoExtraible inherits ObjetoDeInteraccion
{
	const recursoExtraible
	const itemRaro = null
	const cantidadTotal
	
	var cantidadActual
	
	// Extrae suemore y cuando haya cantidad para extraer y se remueve el visual al terminarse
	method extraer(cantidadAExtraer)
	{
		if(cantidadActual >= cantidadAExtraer)
		{
			recursoExtraible.agregar(cantidadAExtraer)
			cantidadActual = cantidadActual - cantidadAExtraer
		}
		else
		{
			recursoExtraible.agregar(cantidadActual)
			cantidadActual = 0
		}
		
		// Si es posible obtener un item raro hay un 2% de posibilidad de obtenerlo en cada extraccion
		if(itemRaro != null and probabilidad.en100De(2))
			itemRaro.agregarAInventario()
	}
	
	override method total() = cantidadTotal
	override method progreso() = cantidadTotal - cantidadActual
}
class Arbol inherits ObjetoExtraible
{
	const property image = null
	
	constructor()
	{
		recursoExtraible = madera
		cantidadTotal = 50
		cantidadActual = cantidadTotal 
	}
	
	override method extraer(cantidadAExtraer)
	{
		super(cantidadAExtraer)
		// Si es posible obtener un item raro hay un 20% de posibilidad de obtenerlo en cada extraccion
		if(probabilidad.en100De(20))
			new Palo(1).agregarAInventario()
	}
	override method progresar() 
	{
		self.extraer(interactores.size())
	}
	
	override method terminar()
	{
		super()
		game.removeVisual(self)
	}
}
class ArbolVerde inherits Arbol
{
	constructor(numero) = super()
	{
		itemRaro = new HierbaVerde(0.randomUpTo(3).roundUp()) // Se obtienen entre 0 y 3 Hierbas Verdes
		image = "assets/Terreno/Recursos/Arbol_1_" + numero + ".png"
	}
}
class ArbolVerdeOscuro inherits Arbol
{
	constructor(numero) = super()
	{
		itemRaro = new HierbaVerde(0.randomUpTo(3).roundUp()) // Se obtienen entre 0 y 3 Hierbas Verdes
		image = "assets/Terreno/Recursos/Arbol_2_" + numero + ".png"
	}
}
class ArbolNaranja inherits Arbol
{
	constructor(numero) = super()
	{
		itemRaro = new HierbaVerde(0.randomUpTo(3).roundUp()) // Se obtienen entre 0 y 3 Hierbas Verdes
		image = "assets/Terreno/Recursos/Arbol_3_" + numero + ".png"
	}
}
class ArbolNevado inherits Arbol
{
	constructor(numero) = super()
	{
		itemRaro = new HierbaVerde(0.randomUpTo(3).roundUp()) // Se obtienen entre 0 y 3 Hierbas Verdes
		image = "assets/Terreno/Recursos/Arbol_4_" + numero + ".png"
	}
}
class ArbolPelado inherits Arbol
{
	constructor(numero) = super()
	{
		itemRaro = new HierbaVerde(0.randomUpTo(3).roundUp()) // Se obtienen entre 0 y 3 Hierbas Verdes
		image = "assets/Terreno/Recursos/Arbol_5_" + numero + ".png"
	}
}
class Roca inherits ObjetoExtraible
{
	const tipo
	
	constructor()
	{
		recursoExtraible = piedra
		cantidadTotal = 50
		cantidadActual = cantidadTotal
		itemRaro = new Rubi()
	
		tipo = [1, 2].anyOne()
	}
	
	override method progresar() 
	{
		self.extraer(interactores.size())
	}
	
	override method terminar()
	{
		super()
		game.removeVisual(self)
	}
	
	override method esAtravesable() = false
	override method image() = "assets/Terreno/Recursos/Roca_"+ tipo +".png" 
}

class MinaDeHierro inherits ObjetoExtraible
{	
	constructor()
	{
		recursoExtraible = hierro
		cantidadTotal = 25
		cantidadActual = cantidadTotal
		itemRaro = new Diamante()
	}
	
	override method progresar() 
	{
		self.extraer(interactores.size())
	}
	
	override method terminar()
	{
		super()
		game.removeVisual(self)
	}
	
	override method esAtravesable() = false
	override method image() = "assets/Terreno/Recursos/Mina_De_Hierro.png" 
}

class MinaDeOro inherits ObjetoExtraible
{	
	constructor()
	{
		recursoExtraible = oro
		cantidadTotal = 25
		cantidadActual = cantidadTotal
		itemRaro = new Diamante()
	}
	
	override method progresar() 
	{
		self.extraer(interactores.size())
	}
	
	override method terminar()
	{
		super()
		game.removeVisual(self)
	}
	
	override method esAtravesable() = false
	override method image() = "assets/Terreno/Recursos/Mina_De_Oro.png" 
}