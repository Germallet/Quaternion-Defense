import wollok.game.*
import escenario.*
import sonidos.*
import teclado.*
import personajes.sobrevivientes.*
import interfaz.mensaje.*
import interfaz.contadores.*

object menuDePreparacion
{
	var estado = 0
	const sobrevivientes = [jan, betty, karl, moldor] //moldor karl
	const sobrevivientesSeleccionados = [] //jan, betty, moldor
	var cursorActual
	
	const espaciado = 2
	
	method inicializarSobrevivientes()
	{
		sobrevivientes.forEach({sobreviviente => sobreviviente.reiniciarHabilidades()})
	}
	
	method generar()
	{
		const mayorPosY = 11
		
		teclado.cambiarEstado(estadoMenuDePreparacion)
		game.onTick(400, "Animacion_Menu", { self.avanzarAnimacion() })
		game.addVisualIn(self, game.origin())
		
		new ImagenSimple("assets/Interfaz/MenuDePreparacion/Panel.png").ubicar(3, 3) // Panel de fondo
		new ImagenSimple("assets/Interfaz/MenuDePreparacion/Personajes.png").ubicar(3, mayorPosY)
		new ImagenSimple("assets/Interfaz/MenuDePreparacion/HabilidadesDelPersonaje.png").ubicar(3, mayorPosY - espaciado)
		new ImagenSimple("assets/Interfaz/MenuDePreparacion/HabilidadesDisponibles.png").ubicar(3, mayorPosY - espaciado * 2)
				
		self.generarSelectoresSobrevivientes(mayorPosY)
		self.generarSelectoresHabilidades(mayorPosY - espaciado)
		self.generarSelectoresHabilidadesPosibles(mayorPosY - espaciado * 2)
		cursorContinuar.ubicar(mayorPosY - espaciado * 3)
		
		/* PUNTOS */
		new ImagenSimple("assets/Interfaz/MenuDePreparacion/Puntos.png").ubicar(9, mayorPosY - espaciado * 4)
		game.addVisualIn(new DosDigitos_Unidad(puntos, mostrarUltimoCero), game.at(11, mayorPosY - espaciado * 4))
		game.addVisualIn(new DosDigitos_Decena(puntos, mostrarUltimoCero), game.at(11, mayorPosY - espaciado * 4))
		
		/* COSTE */
		new ImagenSimple("assets/Interfaz/MenuDePreparacion/Coste.png").ubicar(18, mayorPosY - espaciado * 4)
		game.addVisualIn(new DosDigitos_Unidad(self, mostrarUltimoCero), game.at(20, mayorPosY - espaciado * 4))
		game.addVisualIn(new DosDigitos_Decena(self, mostrarUltimoCero), game.at(20, mayorPosY - espaciado * 4))
		
		self.cambiarCursor(cursorDeSobreviviente)
	}
	
	method generarSelectoresSobrevivientes(posY)
	{
		const posX_Inicial = (game.width() / 2) - (sobrevivientes.size() * espaciado / 2) + 1
		
		var desplazamientoX = 0
		sobrevivientes.forEach({sobreviviente =>
			new SelectorSobreviviente(sobreviviente).ubicar(posX_Inicial + desplazamientoX, posY)
			desplazamientoX += espaciado
		})
		
		cursorDeSobreviviente.ubicar(posX_Inicial, posY)
	}
	method generarSelectoresHabilidades(posY)
	{
		const cantidadDeHabilidades = betty.cantidadHabilidades()
		
		const posX_Inicial = (game.width() / 2) - (cantidadDeHabilidades * espaciado / 2) + 1
		
		var desplazamientoX = 0	
		(cantidadDeHabilidades/2).times({ numeroDeHabilidad =>
			new SelectorHabilidadActiva(numeroDeHabilidad-1).ubicar(posX_Inicial + desplazamientoX, posY)
			desplazamientoX += espaciado
		})
		
		(cantidadDeHabilidades/2).times({ numeroDeHabilidad =>
			new SelectorHabilidadPasiva(numeroDeHabilidad-1).ubicar(posX_Inicial + desplazamientoX, posY)
			desplazamientoX += espaciado
		})
		
		cursorDeHabilidadSeleccionada.ubicar(posX_Inicial, posY)
	}
	method generarSelectoresHabilidadesPosibles(posY)
	{
		const cantidadDeHabilidadesPosibles = betty.cantidadHabilidadesPosibles()
		
		const posX_Inicial = (game.width() / 2) - (cantidadDeHabilidadesPosibles * espaciado / 2) + 1
		
		var desplazamientoX = 0	
		cantidadDeHabilidadesPosibles.times({ numeroDeHabilidad =>
			new SelectorHabilidadPosible(numeroDeHabilidad-1).ubicar(posX_Inicial + desplazamientoX, posY)
			desplazamientoX += espaciado
		})
		
		cursorDeHabilidadPosible.ubicar(posX_Inicial, posY)
	}
	
	method cerrar()
	{ 
		game.removeTickEvent("Animacion_Menu")
		game.allVisuals().forEach({visual => game.removeVisual(visual)})
	}
	
	method sePuedeContinuar() = not sobrevivientesSeleccionados.isEmpty()
	method continuar()
	{
		if (self.sePuedeContinuar())
		{
			self.cerrar()
			game.addVisualIn(cargando, game.origin())
			game.schedule(100, 
			{
				escenario.iniciar(sobrevivientesSeleccionados)
				teclado.cambiarEstado(estadoJugando_Normal)
				game.removeVisual(cargando)
			})
		}		
	}
	
	method tieneInterfaz(posicion) = not posicion.allElements().isEmpty()
	
	method image() = "assets/Interfaz/MenuDeInicio/Menu_Animacion_" + estado + ".png"
	
	method avanzarAnimacion() 
	{
		estado++
		if(estado >= 7)
			estado = 0
	}
	method reproducirSonidoOk()
	{
		sonido.reproducir("Cursor.wav")
	}
	method reproducirSonidoError()
	{
		sonido.reproducir("Habilidad_En_Enfriamiento.wav")
	}
	
	method moverArriba()
	{
		self.reproducirSonidoOk()
		cursorActual.moverArriba()
	}
	method moverAbajo()
	{
		self.reproducirSonidoOk()
		cursorActual.moverAbajo()
	}
	method moverIzquierda()
	{
		self.reproducirSonidoOk()
		cursorActual.moverIzquierda()
	}
	method moverDerecha()
	{
		self.reproducirSonidoOk()
		cursorActual.moverDerecha()
	}
	method enter()
	{
		cursorActual.enter()
	}
	
	method esCursorActual(cursor) = cursorActual == cursor
	method cambiarCursor(nuevoCursor)
	{
		cursorActual = nuevoCursor
		nuevoCursor.hacerFoco()
	}
	
	method estaSeleccionado(sobreviviente) = sobrevivientesSeleccionados.contains(sobreviviente)
	method alternarSeleccionSobreviviente(sobreviviente)
	{
		if(self.estaSeleccionado(sobreviviente))
		{
			sobrevivientesSeleccionados.remove(sobreviviente)
			puntos.agregar(sobreviviente.costeTotal())
			sobreviviente.reiniciarHabilidades()
			sonido.reproducir("Cursor.wav")
		}
		else if(puntos.puedePagar(sobreviviente.costeTotal()))
		{
			puntos.quitar(sobreviviente.costeTotal())
			sobrevivientesSeleccionados.add(sobreviviente)
		}
	}
	
	method numeroAMostrar() = cursorActual.coste()
}

object cargando
{	
	method image() = "assets/Interfaz/MenuDeInicio/Menu_Cargando.png" 
}

/******************** Cursores ********************/
class ImagenSimple
{
	const property image
	constructor(imagen)
	{
		image = imagen
	}
	method ubicar(posX, posY)
	{
		game.addVisualIn(self, game.at(posX, posY))
	}
}

class CursorDePreparacion
{
	var position	
	method position() = position
	method imagenSegunEstado() = if(menuDePreparacion.esCursorActual(self)) "Activo" else "Inactivo"
	method image() = "assets/Interfaz/MenuDePreparacion/CursorDePreparacion_" + self.imagenSegunEstado() + ".png" 
	
	method selectorEnCasilla() = game.colliders(self).get(1)
	method seleccion() = self.selectorEnCasilla().seleccion()
	method ubicar(posX, posY)
	{
		position = game.at(posX, posY)
		game.addVisual(self)
	}
	
	//method moverArriba()
	//method moverAbajo()
	//method moverIzquierda()
	//method moverDerecha()
	//method enter()
	method hacerFoco() { mensaje.mostrarInformacionDe(self.seleccion()) }
	method coste() = self.seleccion().coste()
}

object cursorDeSobreviviente inherits CursorDePreparacion
{	
	method sobreviviente() = self.selectorEnCasilla().seleccion()
	
	method moverArriba()
	{
		menuDePreparacion.cambiarCursor(cursorContinuar)
	}
	method moverAbajo()
	{
		menuDePreparacion.cambiarCursor(cursorDeHabilidadSeleccionada)
	}
	method moverIzquierda()
	{
		if(menuDePreparacion.tieneInterfaz(position.left(2)))
		{
			position = position.left(2)
			self.hacerFoco()
		}			
	}
	method moverDerecha()
	{
		if(menuDePreparacion.tieneInterfaz(position.right(2)))
		{
			position = position.right(2)
			self.hacerFoco()
		}	
	}
	method enter()
	{
		menuDePreparacion.alternarSeleccionSobreviviente(self.sobreviviente())
		menuDePreparacion.reproducirSonidoOk()
	}
	
	method obtenerHabilidadActivaPosible(numero) = self.sobreviviente().habilidadActivaPosible(numero)
	method obtenerHabilidadPasivaPosible(numero) = self.sobreviviente().habilidadPasivaPosible(numero)
	
	
	method reemplazarHabilidadActiva(habilidadOriginal, habilidadComprada)
	{
		self.sobreviviente().reemplazarHabilidadActiva(habilidadOriginal, habilidadComprada)
	}
	method reemplazarHabilidadPasiva(habilidadOriginal, habilidadComprada)
	{
		self.sobreviviente().reemplazarHabilidadPasiva(habilidadOriginal, habilidadComprada)
	}
}
object cursorDeHabilidadSeleccionada inherits CursorDePreparacion
{
	method moverArriba()
	{
		menuDePreparacion.cambiarCursor(cursorDeSobreviviente)
	}
	method moverAbajo()
	{
		menuDePreparacion.cambiarCursor(cursorDeHabilidadPosible)
	}
	method moverIzquierda()
	{
		if(menuDePreparacion.tieneInterfaz(position.left(2)))
		{
			position = position.left(2)
			self.hacerFoco()
		}	
	}
	method moverDerecha()
	{
		if(menuDePreparacion.tieneInterfaz(position.right(2)))
		{
			position = position.right(2)
			self.hacerFoco()
		}	
	}
	method enter()
	{
		menuDePreparacion.reproducirSonidoError()
	}

	method obtenerHabilidadPosible(numero) = self.selectorEnCasilla().obtenerHabilidadPosible(numero)
	method reemplazarHabilidad(habilidadComprada)
	{
		self.selectorEnCasilla().reemplazarHabilidad(habilidadComprada)
	}
}
object cursorDeHabilidadPosible inherits CursorDePreparacion
{
	method moverArriba()
	{
		menuDePreparacion.cambiarCursor(cursorDeHabilidadSeleccionada)
	}
	method moverAbajo()
	{
		menuDePreparacion.cambiarCursor(cursorContinuar)
	}
	method moverIzquierda()
	{
		if(menuDePreparacion.tieneInterfaz(position.left(2)))
		{
			position = position.left(2)
			self.hacerFoco()
		}	
	}
	method moverDerecha()
	{
		if(menuDePreparacion.tieneInterfaz(position.right(2)))
		{
			position = position.right(2)
			self.hacerFoco()
		}	
	}
	
	method puedeComprarHabilidad(habilidadOriginal, habilidadNueva) = not cursorDeSobreviviente.seleccion().tieneHabilidad(habilidadNueva) and puntos.puedePagar(habilidadNueva.coste() - habilidadOriginal.coste())
	method enter()
	{
		const habilidadOriginal = cursorDeHabilidadSeleccionada.seleccion()
		const habilidadNueva = self.seleccion()
		if (self.puedeComprarHabilidad(habilidadOriginal, habilidadNueva))
		{
			puntos.agregar(habilidadOriginal.coste())
			puntos.quitar(habilidadNueva.coste())
			cursorDeHabilidadSeleccionada.reemplazarHabilidad(habilidadNueva)
			menuDePreparacion.reproducirSonidoOk()
		}
		else
			menuDePreparacion.reproducirSonidoError()
	}
}
object cursorContinuar inherits CursorDePreparacion
{
	override method image() = "assets/Interfaz/MenuDePreparacion/BotonJugar_" + self.imagenSegunEstado() + ".png" 
	
	method ubicar(posY)
	{
		self.ubicar((game.width() / 2) - 1, posY)
	}
	
	method moverArriba()
	{
		menuDePreparacion.cambiarCursor(cursorDeHabilidadPosible)
	}
	method moverAbajo()
	{
		menuDePreparacion.cambiarCursor(cursorDeSobreviviente)
	}
	method moverIzquierda() {}
	method moverDerecha() {}
	method enter()
	{
		menuDePreparacion.reproducirSonidoOk()
		menuDePreparacion.continuar()		
	}
	
	override method hacerFoco() { mensaje.ocultar()	}
	override method coste() = 0
}

/******************** Selector ********************/
class SelectorSobreviviente
{
	const sobreviviente
	
	constructor(_sobreviviente)
	{
		sobreviviente = _sobreviviente
	}	
	
	method estadoPorSeleccion() = if(menuDePreparacion.estaSeleccionado(self.seleccion())) return "Abajo" else return "Arriba"
	method image() = "assets/Personajes/Sobrevivientes/" + self.seleccion().nombre() + "/" + self.estadoPorSeleccion() + ".png" 
	method ubicar(posX, posY)
	{
		new ImagenSimple("assets/Interfaz/Marco/Interfaz_Marco_Grande.png").ubicar(posX, posY)
		game.addVisualIn(self, game.at(posX, posY))		
	}
	method seleccion() = sobreviviente
}
class SelectorHabilidadActiva
{
	const numeroDeHabilidad
	
	constructor(_numeroDeHabilidad)
	{
		numeroDeHabilidad = _numeroDeHabilidad
	}
	method image() = self.seleccion().image()
	
	method ubicar(posX, posY)
	{
		new ImagenSimple("assets/Interfaz/Marco/Interfaz_Marco_Grande.png").ubicar(posX, posY)
		game.addVisualIn(self, game.at(posX, posY))
	}
	
	method seleccion() = cursorDeSobreviviente.sobreviviente().habilidadActiva(numeroDeHabilidad)
	method obtenerHabilidadPosible(numero) = cursorDeSobreviviente.obtenerHabilidadActivaPosible(numero)
	
	method reemplazarHabilidad(nuevaHabilidad)
	{
		cursorDeSobreviviente.reemplazarHabilidadActiva(self.seleccion(), nuevaHabilidad)
	}
}
class SelectorHabilidadPasiva
{
	const numeroDeHabilidad
	
	constructor(_numeroDeHabilidad)
	{
		numeroDeHabilidad = _numeroDeHabilidad
	}
	
	method image() = self.seleccion().image()
	
	method ubicar(posX, posY)
	{
		new ImagenSimple("assets/Interfaz/Marco/Interfaz_Marco_Grande.png").ubicar(posX, posY)
		game.addVisualIn(self, game.at(posX, posY))
	}
	
	method seleccion() = cursorDeSobreviviente.seleccion().habilidadPasiva(numeroDeHabilidad)
	method obtenerHabilidadPosible(numero) = cursorDeSobreviviente.obtenerHabilidadPasivaPosible(numero)
	
	method reemplazarHabilidad(nuevaHabilidad)
	{
		cursorDeSobreviviente.reemplazarHabilidadPasiva(self.seleccion(), nuevaHabilidad)
	}
}
class SelectorHabilidadPosible
{
	const numeroDeHabilidad
	
	constructor(_numeroDeHabilidad)
	{
		numeroDeHabilidad = _numeroDeHabilidad
	}
	
	method image() = self.seleccion().image()
	
	method ubicar(posX, posY)
	{
		new ImagenSimple("assets/Interfaz/Marco/Interfaz_Marco_Grande.png").ubicar(posX, posY)
		game.addVisualIn(self, game.at(posX, posY))
	}
	
	method seleccion() = cursorDeHabilidadSeleccionada.obtenerHabilidadPosible(numeroDeHabilidad)
}

/******************** Puntos ********************/
object puntos
{
	var puntos = 5
	
	method numeroAMostrar() = puntos
	method agregar(adicion)
	{
		puntos += adicion
	}
	method quitar(substraccion)
	{
		puntos -= substraccion
	}
	method puedePagar(coste) = puntos >= coste
}