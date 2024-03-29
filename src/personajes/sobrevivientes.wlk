import wollok.game.*
import personajes.*
import escenario.*
import items.equipos.*
import habilidades.*
import interfaz.inventarioGeneral.*
import objetosEnJuego.imagenEnlazada.*
import sonidos.*
import eventos.*
import direcciones.*

/******************** Clase Sobreviviente ********************/	
class Sobreviviente inherits Personaje 
{
	var property equipoDeMano = new NingunEquipo()
	var property casco = new NingunEquipo()
	var property pechera = new NingunEquipo()
	var property pantalones = new Calzoncillos(usuario = self, estado = equipado)
	var property botas = new NingunEquipo()
	
	var ataquePorNivel 
	var defensaPorNivel 
	var vidaPorNivel
	
	var nivel = 1
	var experienciaActual = 0
	
	const habilidadesActivasIniciales = [new HabilidadActiva(), new HabilidadActiva(), new HabilidadActiva()]
	const habilidadesPasivasIniciales = [new HabilidadPasiva(), new HabilidadPasiva(), new HabilidadPasiva()]
	
	const habilidadesActivasAdicionales = [new HabilidadActiva(), new HabilidadActiva(), new HabilidadActiva(), new HabilidadActiva(), new HabilidadActiva()]
	const habilidadesPasivasAdicionales = [new HabilidadPasiva(), new HabilidadPasiva(), new HabilidadPasiva(), new HabilidadPasiva(), new HabilidadPasiva()]
	
	var habilidadesActivas = []
	var habilidadesPasivas =[]

	var objetoDeInteraccion = null
		
	/******************** Combate ********************/	
	method multiplicadorDeDanio() = 50
	
	// Suma de defensa del sobreviviente y la defensa de todos sus equipos
	override method defensa() = ((defensa + defensaPorNivel * nivel) + arma.defensa() + equipoDeMano.defensa() + casco.defensa() + pechera.defensa() + pantalones.defensa() + botas.defensa()) * self.multiplicadorDeDefensa()
	
	method defensaBase() = defensa
	
	method defensaPorNivel() = defensaPorNivel
	
	// Fuerza del sobreviviente en funcion de su nivel
	override method ataque() = 0.max(super() + ataquePorNivel * nivel)
	
	method ataquePorNivel() = ataquePorNivel
	
	// Vida Maxima del sobreviviente en funcion de su nivel
	override method vidaMaxima() = vidaMaxima + vidaPorNivel * nivel
	
	method vidaPorNivel() = vidaPorNivel
	
	override method constanteDeDanioRecibido() = super() - (arma.reduccionDeDanio() + equipoDeMano.reduccionDeDanio() + casco.reduccionDeDanio() + pechera.reduccionDeDanio() + pantalones.reduccionDeDanio() + botas.reduccionDeDanio())
	
	override method recibirAtaqueNormal(danio, agresor)
	{
		super(danio, agresor)
		[arma, equipoDeMano, casco, pechera, pantalones, botas].forEach{ equipo => equipo.recibioAtaque(danio, agresor) }
	}
	
	// Obtiene un enemigo dentro del rando de ataque
	override method objetivoEnRango() = escenario.enemigos().filter{ enemigo => arma.estaEnRango(enemigo) and enemigo.esAtacable() }.anyOne()
	
	// Comprueba que haya al menos un enemigo en rango de ataque
	override method hayObjetivosEnRango() = escenario.enemigos().any{ enemigo => arma.estaEnRango(enemigo) and enemigo.esAtacable() }
	
	override method matasteA(muerto)
	{
		self.ganarExperiencia(muerto.experienciaQueDa())
		super(muerto)
	}
	
	/******************** Nivel ********************/
	method nivel() = nivel
	
	method experienciaParaPasarDeNivel() = (1+nivel)**(2) //4/9/16/25
	
	method ganarExperiencia(experienciaGanada)
	{
		if(nivel <5)
		{
			const experienciaParaPasarDeNivel = self.experienciaParaPasarDeNivel()
			
			if(experienciaActual + experienciaGanada <= experienciaParaPasarDeNivel)
				experienciaActual = experienciaActual + experienciaGanada
			else
			{
				self.subirDeNivel()
				self.ganarExperiencia(experienciaActual + experienciaGanada - experienciaParaPasarDeNivel)
			}
		}
	}
	
	method subirDeNivel()
	{
		nivel ++
		experienciaActual = 0
		
		self.curar(2*vidaPorNivel)
	}
	
	method reiniciarNiveles()
	{
		nivel = 1
		experienciaActual = 0
	}
	/******************** Inventario ********************/
	method equiparManos() { arma = new Manos(usuario = self, estado = equipado) }
	
	// Desequipar un equipo especifico en el sobreviviente
	method desequiparTodo()
	{
		self.arma().desequipar()
		self.equipoDeMano().desequipar()
		self.casco().desequipar()
		self.pechera().desequipar()
		self.pantalones().desequipar()
		self.botas().desequipar()
	}
	
	// Verifica si tiene equipos
	method tiene(equipo) = not equipo.esMismoItem(new NingunEquipo()) and not equipo.esMismoItem(new Manos())
	
	override method agarrarItem(item) { item.serAgarrado() }
	
	/******************** Interacciones ********************/
	// Mensaje para interactuar con un objeto
	override method interactuarCon(objeto)
	{
		objeto.interactuarCon(self)
	}
	
	method dejarDeInteractuarSiLoEstaHaciendo()
	{
		if(self.estaInteractuando())
			objetoDeInteraccion.dejarDeInteractuarCon(self)
	}
	
	method establecerObjetoDeInteraccion(_objetoDeInteraccion)  
	{
		objetoDeInteraccion = _objetoDeInteraccion
	}
	method estaInteractuando() = objetoDeInteraccion != null
	
	// Al moverse se finaliza la Interaccion
	override method moverHaciaSiEsPosible(direccion)
	{
		super(direccion)
		self.dejarDeInteractuarSiLoEstaHaciendo()
		sonido.reproducir("Pisada_En_Suelo.wav")
	}
	
	/******************** Habilidades ********************/
	// Activa la habilidad del sobreviviente y finaliza la interaccion si se entonctraba en una
	method activarHabilidad(n)
	{
		habilidadesActivas.get(n).activar()
		self.dejarDeInteractuarSiLoEstaHaciendo()
	}
		
	method reemplazarHabilidad(original, nueva)
	{
		habilidadesActivas = habilidadesActivas.map({
			habilidad =>
			if (habilidad == original)
				return nueva			
			else
				return habilidad
		})
		habilidadesPasivas = habilidadesPasivas.map({
			habilidad =>
			if (habilidad == original)
				return nueva
			else
				return habilidad
		})
		
		original.desequipar()
		nueva.equiparEn(self)
	}
	
	method equiparHabilidadesIniciales()
	{
		habilidadesActivas.forEach{ habilidad => habilidad.desequipar() }		
		habilidadesPasivas.forEach{ habilidad => habilidad.desequipar() }
		
		habilidadesActivas = habilidadesActivasIniciales.copy()
		habilidadesPasivas = habilidadesPasivasIniciales.copy()
		
		habilidadesActivas.forEach{ habilidad => habilidad.equiparEn(self) }		
		habilidadesPasivas.forEach{ habilidad => habilidad.equiparEn(self) }
	}
	
	method desequiparHabilidades()
	{
		habilidadesActivas.forEach{ habilidad => habilidad.desequipar() }		
		habilidadesPasivas.forEach{ habilidad => habilidad.desequipar() }
		
		habilidadesActivas = habilidadesActivasIniciales.copy()
		habilidadesPasivas = habilidadesPasivasIniciales.copy()
	}
	
	method cantidadHabilidades() = habilidadesActivas.size() + habilidadesPasivas.size()
	method habilidadActiva(n) = habilidadesActivas.get(n)
	method habilidadPasiva(n) = habilidadesPasivas.get(n)

	method habilidadesActivasPosibles() = (habilidadesActivasIniciales + habilidadesActivasAdicionales)
	method habilidadesPasivasPosibles() = (habilidadesPasivasIniciales + habilidadesPasivasAdicionales)
	
	method cantidadHabilidadesPosibles() = self.habilidadesActivasPosibles().size()	
	method habilidadActivaPosible(n) = self.habilidadesActivasPosibles().get(n)
	method habilidadPasivaPosible(n) = self.habilidadesPasivasPosibles().get(n)
	
	method tieneHabilidad(habilidad) = habilidadesActivas.contains(habilidad) or habilidadesPasivas.contains(habilidad)
	
	// Morir
	override method efectoAlMorir(asesino)
	{	
		self.desequiparTodo()
		escenario.removerSobreviviente(self)
	}
	
	/******************** Eventos ********************/
	override method eventos() =
	[
		new EventoPeriodico(eventos1Segundo, self.tiempoDeAccion(), { self.atacarSiHayObjetivosEnRango() })
	]
	
	/******************** Otros ********************/
	method reiniciar()
	{	
		self.curarTodo()
		self.reiniciarComportamientos()
		self.desequiparTodo()
	}
	
	override method image() = "assets/Personajes/Sobrevivientes/" + self.nombre() + "/" + self.estadoDeAnimacion() + ".png" // Obtiene la imagen de la carpeta assets aprovechando para donde mira el sobreviviente
	override method inicializar() { super() orientacion = derecha }
	method agarrarDrop(drop) { drop.serAgarrado() }
	
	method coste() = 1
	method costeTotal() = self.coste() + habilidadesActivas.sum({habilidad => habilidad.coste()}) + habilidadesPasivas.sum({habilidad => habilidad.coste()})
	method informacion() = "Sobrevivientes/" + self.nombre()
}

/**************************************** Sobrevivientes ****************************************/	

/******************** Jan ********************/
object jan inherits Sobreviviente
(
	arma = manosDeJan, 
	
	habilidadesActivasIniciales = [new CocktailMolotov(usuario = jan), new FlechazoSimple(usuario = jan), new Regeneracion(categoria = regeneracionNormal, usuario = jan)],
	habilidadesPasivasIniciales = [new Valentia(estadistica = estadisticaNormal, usuario = jan), new Escudo(estadistica = estadisticaNormal, usuario = jan), new Proteccion(estadistica = estadisticaNormal, usuario = jan)],
	
	habilidadesActivasAdicionales = [new FlechazoIgneo(), new FlechazoGelido(), new FlechazoOscuro(), new FlechazoPerforante()],
	habilidadesPasivasAdicionales = [new Valentia(estadistica = estadisticaMas), new Valentia(estadistica = estadisticaMasMas), new Escudo(estadistica = estadisticaMas), new Escudo(estadistica = estadisticaMasMas), new Proteccion(estadistica = estadisticaMasMas)],
	
	vidaMaxima = 100, 
	vidaPorNivel = 16.8, 
	
	ataque = 12, 
	ataquePorNivel = 8.8, 
	
	defensa = 20, 
	defensaPorNivel = 8.2
)
{
	override method nombre() = "Jan"
	
	override method matasteA(muerto)
	{
		super(muerto)
		manosDeJan.mato()
	}
	
	override method equiparManos() { arma = manosDeJan }
}

/******************** Betty ********************/
object betty inherits Sobreviviente
(
	arma = new Manos(usuario = betty, estado = equipado), 
	
	habilidadesActivasIniciales = [new Cura(categoria = curaNormal, usuario = betty), new Regeneracion(categoria = regeneracionNormal, usuario = betty), new Revivir(categoria = revivirNormal, usuario = betty)],
	habilidadesPasivasIniciales = [new Vida(estadistica = estadisticaNormal, usuario = betty), new Escudo(estadistica = estadisticaNormal, usuario = betty), new Valentia(estadistica = estadisticaNormal, usuario = betty)],
	
	habilidadesActivasAdicionales = [new Cura(categoria = curaMas), new Cura(categoria = curaMasMas),  new Regeneracion(categoria = regeneracionMas), new Revivir(categoria = revivirMasMas)],
	habilidadesPasivasAdicionales = [new Vida(estadistica = estadisticaMas), new Vida(estadistica = estadisticaMasMas), new Escudo(estadistica = estadisticaMasMas), new AutoRevivir() ],
	
	vidaMaxima = 100, 
	vidaPorNivel = 27, 
	
	ataque = 14, 
	ataquePorNivel = 5.4, 
	
	defensa = 16, 
	defensaPorNivel = 5.8
)
{
	var numeroDeAtaque = 0
	override method nombre() = "Betty"
	override method atacarSiHayObjetivosEnRango()
	{
		if(self.hayObjetivosEnRango())
		{
			numeroDeAtaque++
			super()
			if(numeroDeAtaque == 3) 
			{
				self.curar(self.porcentajeDeVidaMaxima(5))
				numeroDeAtaque = 0
			}
		}
	}

}

/******************** Karl ********************/
object karl inherits Sobreviviente
(
	arma = new Manos(usuario = karl, estado = equipado), 
	
	habilidadesActivasIniciales = [new AtaqueDeExperiencia(usuario = karl), new AtaqueSimple(usuario = karl), new Cura(categoria = curaNormal, usuario = karl)],
	habilidadesPasivasIniciales = [new Valentia(estadistica = estadisticaNormal, usuario = karl), new Critico(estadistica = estadisticaNormal, usuario = karl), new Despiadado(estadistica = estadisticaNormal, usuario = karl)],
	
	habilidadesActivasAdicionales = [new AtaqueIgneo(), new AtaqueGelido(), new AtaqueOscuro(), new AtaquePerforante()],
	habilidadesPasivasAdicionales = [new Valentia(estadistica = estadisticaMasMas), new Critico(estadistica = estadisticaMas), new Critico(estadistica = estadisticaMasMas), new Despiadado(estadistica = estadisticaMas)],
	
	vidaMaxima = 100, 
	vidaPorNivel = 9, 
	
	ataque = 16, 
	ataquePorNivel = 6.8, 
	
	defensa = 16, 
	defensaPorNivel = 7, 
	
	probabilidadDeEvasion = 15, 
	probabilidadDeCritico = 15
)
{
	const escudo = new BarraDeEscudo(self)
	var escudoActual = 0
	
	override method nombre() = "Karl"
	
	override method vidaMaxima() = super()/2
	
	method escudoMaximo() = self.vidaMaxima()
	method escudoActual() = escudoActual
	
	method modificarEscudoActual(modificacion) { escudoActual = 0.max(self.escudoMaximo().min(escudoActual + modificacion)) }
	
	override method inicializar(posicion) {	super(posicion) game.addVisual(escudo) }
	
	override method eventos() = super() + [ new EventoPeriodico(eventos1Segundo, 4, { self.modificarEscudoActual(5 + nivel * 0.5) })	]
	
	override method sufrirDanio(danio, agresor)
	{
		if(escudoActual != 0)
		{
			self.modificarEscudoActual(-danio)
		}
		else
			super(danio, agresor)
	}
	
	override method matasteA(muerto) { super(muerto) self.modificarEscudoActual(5 + nivel) }
	
	override method efectoAlMorir(asesino) { game.removeVisual(escudo) }
}

/******************** Karl ********************/
object moldor inherits Sobreviviente
(
	arma = new Manos(usuario = moldor, estado = equipado), 
	
	habilidadesActivasIniciales = [new AtaqueDeExperiencia(usuario = moldor), new Cura(categoria = curaNormal, usuario = moldor), cambioDeEnergias],
	habilidadesPasivasIniciales = [new Valentia(estadistica = estadisticaNormal, usuario = moldor), new Escudo(estadistica = estadisticaNormal, usuario = moldor), new Vida(estadistica = estadisticaNormal, usuario = moldor)],
	
	habilidadesActivasAdicionales = [new Revivir(categoria = revivirMas), new FlechazoPerforante(), new AtaqueOscuro(), oracion],
	habilidadesPasivasAdicionales = [new Valentia(estadistica = estadisticaMas), new Vida(estadistica = estadisticaMas), new Escudo(estadistica = estadisticaMas), enteInterno],
	
	vidaMaxima = 100, 
	vidaPorNivel = 17, 
	
	ataque = 14, 
	ataquePorNivel = 4.2, 
	
	defensa = 20, 
	defensaPorNivel = 10.3
)
{
	var property modo = moldorNormal
	
	override method nombre() = modo.nombre()
	
	method supuestoAtaque() =  0.max(ataquePerforante + arma.ataquePerforante() + ataquePorNivel * nivel)
	
	method supuestaDefensa() = (defensa + defensaPorNivel * nivel) + arma.defensa() + equipoDeMano.defensa() + casco.defensa() + pechera.defensa() + pantalones.defensa() + botas.defensa()
	
	override method ataque() = modo.ataque()
	
	override method defensa() = modo.defensa()
	
	method cambiarModo() 
	{ 
		modo.cambiarModo()
		enteInterno.cambiarModo()
	}
}

object moldorNormal
{
	method nombre() = "Moldor"
	
	method energia() = "Energia_Positiva"
	
	method ataque() = moldor.supuestoAtaque()
	
	method defensa() = moldor.supuestaDefensa()
	
	method cambiarModo() { moldor.modo(moldorOscuro) }

	method modoOpuesto() = moldorOscuro

	method oracion() = bendicion
}

object moldorOscuro
{
	method nombre() = "Moldor Oscuro"
	
	method energia() = "Energia_Negativa"
	
	method ataque() = moldor.supuestaDefensa()
	
	method defensa() = moldor.supuestoAtaque()
	
	method cambiarModo() { moldor.modo(moldorNormal) }
	
	method modoOpuesto() = moldorNormal
	
	method oracion() = maldicion
}



