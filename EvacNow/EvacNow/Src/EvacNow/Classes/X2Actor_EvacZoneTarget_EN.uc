//---------------------------------------------------------------------------------------
//  *********   FIRAXIS SOURCE CODE   ******************
//  FILE:    X2Actor_EvacZoneTarget.uc
//  AUTHOR:  David Burchanowski
//  PURPOSE: Targeting visuals for the X2TargetingMethod_EvacZone targeting method
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//--------------------------------------------------------------------------------------- 

class X2Actor_EvacZoneTarget_EN extends StaticMeshActor;

var const string MeshPath, BadMeshPath, UnsafeMeshPath;

var private StaticMesh ZoneMesh, BadMesh, UnsafeMesh;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	ZoneMesh = StaticMesh(`CONTENT.RequestGameArchetype(default.MeshPath));
	`assert(ZoneMesh != none);	
	BadMesh = StaticMesh(`CONTENT.RequestGameArchetype(default.BadMeshPath));
	`assert(BadMesh != none);

	UnsafeMesh = StaticMesh(`CONTENT.RequestGameArchetype(default.UnsafeMeshPath));
	`assert(UnsafeMesh != none);
}

simulated function ShowBadMesh()
{
	if (StaticMeshComponent.StaticMesh != BadMesh)
		StaticMeshComponent.SetStaticMesh(BadMesh);
}

simulated function ShowGoodMesh()
{
	if (StaticMeshComponent.StaticMesh != ZoneMesh)
		StaticMeshComponent.SetStaticMesh(ZoneMesh);
}

simulated function ShowUnsafeMesh()
{
	if (StaticMeshComponent.StaticMesh != UnsafeMesh)
		StaticMeshComponent.SetStaticMesh(UnsafeMesh);
}

DefaultProperties
{
	Begin Object Name=StaticMeshComponent0
		bOwnerNoSee=FALSE
		CastShadow=FALSE
		CollideActors=FALSE
		BlockActors=FALSE
		BlockZeroExtent=FALSE
		BlockNonZeroExtent=FALSE
		BlockRigidBody=FALSE
		HiddenGame=FALSE
	End Object	

	bStatic=FALSE
	bWorldGeometry=FALSE
	bMovable=TRUE
	UnsafeMeshPath = "UI_3D_EvacNow.Evacuation.EvacLocation_Unsafe"
	MeshPath = "UI_3D.Evacuation.EvacLocation"
	BadMeshPath = "UI_3D.Evacuation.EvacLocation_Obstructed"
}
