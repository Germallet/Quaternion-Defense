import wollok.game.*
import escenario.*
import direcciones.*
import interfaz.cursores.*
import menues.menuDeInicio.*
import menues.menuDePreparacion.*
import interfaz.mensaje.*
import reloj.*
import interfaz.inventarioGeneral.*

object teclado
{
	var estadoDeJuegoActual = estadoMenuDeInicio
	
	method configurarTeclas()
	{
		keyboard.w().onPressDo({estadoDeJuegoActual.onPressW()})
		keyboard.a().onPressDo({estadoDeJuegoActual.onPressA()})
		keyboard.s().onPressDo({estadoDeJuegoActual.onPressS()})
		keyboard.d().onPressDo({estadoDeJuegoActual.onPressD()})
		keyboard.up().onPressDo({estadoDeJuegoActual.onPressUp()})
		keyboard.down().onPressDo({estadoDeJuegoActual.onPressDown()})
		keyboard.left().onPressDo({estadoDeJuegoActual.onPressLeft()})
		keyboard.right().onPressDo({estadoDeJuegoActual.onPressRight()})
		keyboard.enter().onPressDo({estadoDeJuegoActual.onPressEnter()})
		keyboard.space().onPressDo({estadoDeJuegoActual.onPressSpace()})
		keyboard.shift().onPressDo({estadoDeJuegoActual.onPressShift()})
		keyboard.num0().onPressDo({estadoDeJuegoActual.onPressNum0()})
		keyboard.num1().onPressDo({estadoDeJuegoActual.onPressNum1()})
		keyboard.num2().onPressDo({estadoDeJuegoActual.onPressNum2()})
		keyboard.num3().onPressDo({estadoDeJuegoActual.onPressNum3()})
		keyboard.num4().onPressDo({estadoDeJuegoActual.onPressNum4()})
		keyboard.num5().onPressDo({estadoDeJuegoActual.onPressNum5()})
		keyboard.num6().onPressDo({estadoDeJuegoActual.onPressNum6()})
		keyboard.e().onPressDo({estadoDeJuegoActual.onPressE()})
		keyboard.f().onPressDo({estadoDeJuegoActual.onPressF()})	
		keyboard.p().onPressDo({estadoDeJuegoActual.onPressP()})
		keyboard.r().onPressDo({estadoDeJuegoActual.onPressR()})
		keyboard.b().onPressDo({estadoDeJuegoActual.onPressB()})
		keyboard.v().onPressDo({estadoDeJuegoActual.onPressV()})
		keyboard.c().onPressDo({estadoDeJuegoActual.onPressC()})
	}
	method cambiarEstado(nuevoEstado) { estadoDeJuegoActual = nuevoEstado }
}

class EstadoDeJuego
{
	method onPressW() {}
	method onPressA() {}
	method onPressS() {}
	method onPressD() {}
	method onPressUp() {}
	method onPressDown() {}
	method onPressLeft() {}
	method onPressRight() {}
	method onPressEnter() {}
	method onPressSpace() {}
	method onPressShift() {}
	method onPressNum0() {}
	method onPressNum1() {}
	method onPressNum2() {}
	method onPressNum3() {}
	method onPressNum4() {}
	method onPressNum5() {}
	method onPressNum6() {}	
	method onPressE() {}
	method onPressF() {}		
	method onPressR() {}
	method onPressB() {}
	method onPressV() {}
	method onPressC() {}
	method onPressP() {}
}

object estadoMenuDeInicio inherits EstadoDeJuego
{
	override method onPressEnter() { menuDeInicio.continuar() }
}
object estadoMenuDePreparacion inherits EstadoDeJuego
{
	override method onPressUp() { menuDePreparacion.moverArriba() }
	override method onPressDown() { menuDePreparacion.moverAbajo() }
	override method onPressLeft() { menuDePreparacion.moverIzquierda() }
	override method onPressRight() { menuDePreparacion.moverDerecha() }
	override method onPressEnter() { menuDePreparacion.enter() }		
}
class EstadoJugando inherits EstadoDeJuego
{
	override method onPressW() { escenario.sobrevivienteSeleccionado().moverHaciaSiEsPosible(arriba) }
	override method onPressS() { escenario.sobrevivienteSeleccionado().moverHaciaSiEsPosible(abajo) }
	override method onPressA() { escenario.sobrevivienteSeleccionado().moverHaciaSiEsPosible(izquierda) }
	override method onPressD() { escenario.sobrevivienteSeleccionado().moverHaciaSiEsPosible(derecha) }
	
	override method onPressUp() { cursorDeInventario.moverArriba() }
	override method onPressDown() { cursorDeInventario.moverAbajo() }
	override method onPressLeft() { cursorDeInventario.moverIzquierda() }
	override method onPressRight() { cursorDeInventario.moverDerecha() }
	
	override method onPressSpace() { escenario.alternarSobreviviente() }
	
	override method onPressShift() {
		teclado.cambiarEstado(estadoJugando_Shift)
		game.schedule(500, {teclado.cambiarEstado(estadoJugando_Normal)})
	}
	
	override method onPressNum0() { cursorDeInventario.itemSeleccionado().interactuar() }
	override method onPressE() { cursorDeInventario.itemSeleccionado().interactuar() }
	
	override method onPressF() { escenario.sobrevivienteSeleccionado().interactuarCon(escenario.sobrevivienteSeleccionado().objetoDeEnFrente()) }
	override method onPressR() { mensaje.mostrarInformacionDe(escenario.sobrevivienteSeleccionado(), 5000) }
	override method onPressV() { mensaje.mostrarInformacionDe(cursorDeInventario.itemSeleccionado(), 5000) }
	override method onPressB() { inventarioGeneral.removerItem(cursorDeInventario.itemSeleccionado()) }
	override method onPressC() { cursorDeInventario.itemSeleccionado().combinar() }
	override method onPressP() { reloj.activarPausa() }
}
object estadoJugando_Normal inherits EstadoJugando
{
	override method onPressNum1() { escenario.sobrevivienteSeleccionado().activarHabilidad(0) }
	override method onPressNum2() { escenario.sobrevivienteSeleccionado().activarHabilidad(1) }
	override method onPressNum3() { escenario.sobrevivienteSeleccionado().activarHabilidad(2) }
}
object estadoJugando_Shift inherits EstadoJugando
{
	override method onPressNum1() { mensaje.mostrarInformacionDe(escenario.sobrevivienteSeleccionado().habilidadActiva(0), 5000) }
	override method onPressNum2() { mensaje.mostrarInformacionDe(escenario.sobrevivienteSeleccionado().habilidadActiva(1), 5000) }
	override method onPressNum3() { mensaje.mostrarInformacionDe(escenario.sobrevivienteSeleccionado().habilidadActiva(2), 5000) }
	override method onPressNum4() { mensaje.mostrarInformacionDe(escenario.sobrevivienteSeleccionado().habilidadPasiva(0), 5000) }
	override method onPressNum5() { mensaje.mostrarInformacionDe(escenario.sobrevivienteSeleccionado().habilidadPasiva(1), 5000) }
	override method onPressNum6() { mensaje.mostrarInformacionDe(escenario.sobrevivienteSeleccionado().habilidadPasiva(2), 5000) }
}
object estadoPausado inherits EstadoDeJuego
{
	override method onPressP() { reloj.desactivarPausa() }
}